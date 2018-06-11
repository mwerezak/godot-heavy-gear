extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const TerrainTiles = preload("res://scripts/game/data/TerrainTiles.gd")
const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")

var tile_id
var random_seed = 0

func _init(tile_id, random_seed = 0):
	self.tile_id = tile_id
	self.random_seed = random_seed

func create_scatters(world_map, scatter_grid, scatter_radius):
	rand_seed(random_seed)
	
	var scatters = []
	for scatter_data in _scatter_placement(scatter_grid):
		if !inside_hex(scatter_data.position - scatter_grid.position, scatter_radius - scatter_data.info.base_radius):
			continue
		if !can_place_scatter(world_map, scatter_data):
			continue
		
		var scatter = TerrainScatter.new(scatter_data.info)
		scatter.position = scatter_data.position
		scatters.push_back(scatter)
	return scatters

func _scatter_placement(scatter_grid):
	var tile_info = TerrainTiles.get_info(tile_id)
	
	var scatter_scale = 1.0/tile_info.density
	scatter_grid.scale = scatter_scale*Vector2(1,1)
	
	var scatter_data = []
	for scatter_cell in HexUtils.get_spiral(ceil(tile_info.density - 1)):
		var scatter_id = RandomUtils.get_weighted_random(tile_info.scatters)
		if scatter_id != "none":
			var scatter_info = TerrainTiles.SCATTERS[scatter_id]
			var scaled_base_radius = scatter_info.base_radius/(scatter_grid.cell_spacing.x * scatter_scale)
			var scatter_pos = scatter_cell + RandomUtils.get_random_scatter(max(0.5 - scaled_base_radius, 0))

			scatter_data.push_back({
				info = scatter_info,
				position = scatter_grid.axial_to_world(scatter_pos),
			})
	return scatter_data


## I dont understand why a special transform is needed here, but nothing works unless I do this
func get_axial_transform(edge_radius, origin=Vector2()):
	return Transform2D(Vector2(edge_radius, 0), Vector2(0, edge_radius).rotated(deg2rad(30)), origin)

func inside_hex(world_pos, radius):
	var axial_pos = get_axial_transform(1).xform_inv(world_pos)
	var z = -(axial_pos.x + axial_pos.y) #x + y + z = 0
	return abs(axial_pos.x) <= radius && abs(axial_pos.y) <= radius && abs(z) <= radius

func can_place_scatter(world_map, scatter_data):
	var world_pos = scatter_data.position
	var grid_cell = world_map.unit_grid.get_axial_cell(world_pos)

	if grid_cell == Vector2(17, 8):
		print("trace")
	
	## don't place scatters on roads
	if world_map.road_cells.has(grid_cell):
		return false
	
	## check if there are any structures that exclude scatters
	var structure = world_map.get_structure_at_cell(grid_cell)
	if structure && structure.exclude_scatters():
		return false
	
	return true
