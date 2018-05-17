extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const TerrainTiles = preload("res://scripts/terrain/TerrainTiles.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")

export(Vector2) var cell_pos
export(String) var terrain_id
export(int) var scatter_seed = 0

#onready var terrain_map = get_parent()
onready var scatter_grid = $ScatterGrid

func _ready():
	## setup scatter grid
	var terrain_cell = WorldMap.get_terrain_cell_size()
	scatter_grid.position = -terrain_cell/2
	scatter_grid.cell_size = terrain_cell
	
	## TODO clean this up
	if TerrainTiles.OVERLAYS.has(terrain_id):
		rand_seed(scatter_seed)
		var overlay_info = TerrainTiles.OVERLAYS[terrain_id]
		var randweights = {}
		for item in overlay_info.scatters:
			randweights[item] = item.randweight
			
		var placement_info = RandomUtils.get_weighted_random(randweights)
		place_scatters(placement_info)

func _create_scatter(scatter_info):
	var scatter = Sprite.new()
	scatter.texture = RandomUtils.get_random_item(scatter_info.textures)
	scatter.z_as_relative = false
	scatter.z_index = scatter_info.zlayer
	
	if scatter_info.offset == TerrainTiles.ScatterOffset.CENTER:
		scatter.offset.y = -scatter.texture.get_size().y/2
	
	return scatter

func _get_scatter_pos(cell_pos):
	return scatter_grid.map_to_world(cell_pos) * scatter_grid.scale

const TEST_TEXTURE = preload("res://icons/terrain/woodland/flowers0.png")
const scatter_width = 0 ## temp
func place_scatters(placement_info):
	var scatter_scale = 1.0/placement_info.density
	var scatter_radius = scatter_scale*WorldMap.TERRAIN_WIDTH/2
	
	scatter_grid.scale = scatter_scale*Vector2(1,1)
	
	for cell_pos in _hex_spiral(ceil(placement_info.density - 1)):
		var scatter_id = RandomUtils.get_weighted_random(placement_info.scatters)
		if scatter_id != "none":
			var scatter_info = TerrainTiles.SCATTERS[scatter_id]
			var base_radius = scatter_info.base_radius
			var scatter_pos = _get_scatter_pos(cell_pos) + RandomUtils.get_random_scatter(max(scatter_radius - base_radius, 0))
			
			var sprite = Sprite.new()
			sprite.texture = load("res://icons/move_marker_16.png")
			sprite.position = _get_scatter_pos(cell_pos)
			#add_child(sprite)
			
			var scatter = _create_scatter(scatter_info)
			scatter.position = scatter_pos
			add_child(scatter)
			
			if !HexUtils.inside_hex(Vector2(), WorldMap.TERRAIN_WIDTH/2 - base_radius, scatter_pos):
				scatter.modulate = Color(1, 0.5, 0.5)
				scatter.hide()

const _RADIAL_DIR = 0
const _STEP_DIRS = [4, 6, 8, 10, 0, 2]
func _hex_spiral(radius):
	var cur_pos = Vector2(0,0)
	var path = [ cur_pos ]
	for ring in radius:
		cur_pos = HexUtils.get_step(cur_pos, _RADIAL_DIR)
		for step_dir in _STEP_DIRS:
			for i in (ring + 1):
				path.push_back(cur_pos)
				cur_pos = HexUtils.get_step(cur_pos, step_dir)
	return path

