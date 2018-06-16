extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const TerrainTiles = preload("res://scripts/game/data/TerrainTiles.gd")

var world_coords
var tile_id
var random_seed = 0

func _init(world_coords, tile_id, random_seed = 0):
	self.world_coords = world_coords
	self.tile_id = tile_id
	self.random_seed = random_seed

func spawn_scatters(scatter_grid):
	rand_seed(random_seed)

	var scatter_radius = world_coords.terrain_grid.cell_spacing.x/2.0
	var terrain_cell = world_coords.terrain_grid.get_axial_cell(scatter_grid.position)
	
	var scatters = []
	for scatter_data in _scatter_placement(scatter_grid):
		if !inside_terrain_cell(terrain_cell, scatter_data.position):
			continue
		
		scatters.push_back(scatter_data)
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

func inside_terrain_cell(terrain_cell, world_pos):
	return world_coords.terrain_grid.get_axial_cell(world_pos) == terrain_cell
