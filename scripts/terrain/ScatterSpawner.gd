extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const TerrainTiles = preload("res://scripts/terrain/TerrainTiles.gd")
const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")

export(String) var terrain_id
export(int) var scatter_seed = 0

onready var world_map
onready var scatter_grid = $ScatterGrid

func spawn_scatters(world_map):
	self.world_map = world_map
	
	## setup scatter grid
	var terrain_cell = world_map.terrain.cell_size
	scatter_grid.cell_size = terrain_cell
	
	if TerrainTiles.OVERLAYS.has(terrain_id):
		rand_seed(scatter_seed)
		var overlay_info = TerrainTiles.OVERLAYS[terrain_id]
		var randweights = {}
		for item in overlay_info.scatters:
			randweights[item] = item.randweight
			
		var placement_info = RandomUtils.get_weighted_random(randweights)
		_place_scatters(placement_info)

func _place_scatters(placement_info):
	var scatter_scale = 1.0/placement_info.density
	var scatter_radius = scatter_scale*WorldMap.TERRAIN_WIDTH/2
	
	scatter_grid.scale = scatter_scale*Vector2(1,1)
	
	for cell_pos in HexUtils.get_spiral(ceil(placement_info.density - 1)):
		var scatter_id = RandomUtils.get_weighted_random(placement_info.scatters)
		if scatter_id != "none":
			var scatter_info = TerrainTiles.SCATTERS[scatter_id]
			var base_radius = scatter_info.base_radius
			var scatter_pos = _get_scatter_pos(cell_pos) + RandomUtils.get_random_scatter(max(scatter_radius - base_radius, 0))
			
			if _can_place_scatter(scatter_pos, base_radius):
				var scatter = TerrainScatter.new(scatter_info)
				scatter.position = position + scatter_pos
				world_map.add_child(scatter)

func _get_scatter_pos(cell_pos):
	return scatter_grid.map_to_world(cell_pos) * scatter_grid.scale

func _can_place_scatter(scatter_pos, base_radius):
	## make sure the scatter is inside our hex
	if !HexUtils.inside_hex(Vector2(), WorldMap.TERRAIN_WIDTH/2 - base_radius, scatter_pos):
		return false
	
	var world_pos = transform.xform(scatter_pos)
	var cell_pos = world_map.get_grid_cell(world_pos)
	
	## don't place scatters on roads
	if world_map.road_cells.has(cell_pos):
		return false
	
	## check if there are any structures that exclude scatters
	var structure = world_map.get_structure_at_cell(cell_pos)
	if structure && structure.exclude_scatters():
		var cell_center = transform.xform_inv(world_map.get_grid_pos(cell_pos))
		if HexUtils.inside_hex(cell_center, WorldMap.UNITGRID_WIDTH/2 - base_radius, scatter_pos):
			return false
	
	return true
	
