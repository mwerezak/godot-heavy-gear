extends Reference

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const ScatterSpawner = preload("res://scripts/terrain/ScatterSpawner.gd")
const SegmentBuilder = preload("res://scripts/terrain/SegmentBuilder.gd")
const Structure = preload("res://scripts/structures/Structure.tscn")
const Road = preload("res://scripts/terrain/Road.tscn")
const RoadComparer = preload("res://scripts/terrain/Road.gd").ConnectionComparer

var source_map

var map_extents
var global_lighting
var terrain_tileset

var terrain_indexes = {}
var terrain_elevation = {}
var scatter_spawners = {}
var structures = {}
var roads = []

func load_map(world_map, map_scene):
	source_map = map_scene.instance()
	
	map_extents = source_map.map_extents
	global_lighting = source_map.global_lighting
	terrain_tileset = source_map.terrain_tileset
	
	rand_seed(source_map.map_seed) #initialize seed
	
	var editor_map = source_map.get_node("Terrain")
	_generate_terrain(editor_map)
	
	var struct_map = source_map.get_node("Structures")
	_generate_structures(struct_map)
	
	## generate roads
	var road_map = source_map.get_node("Roads")
	var builder = SegmentBuilder.new(world_map.unit_grid, RoadComparer)
	var road_segments = builder.build_segments(road_map)
	for grid_cells in road_segments:
		var road = Road.instance()
		road.setup(world_map, grid_cells)
		roads.push_back(road)
	
	## extract elevation data
	var elevation_map = source_map.get_node("Elevation")
	_extract_elevation(elevation_map)

## rebuild cached terrain indexes and overlays
func _generate_terrain(editor_terrain_map):
	var editor_tileset = editor_terrain_map.get_tileset()
	
	for hex_cell in editor_terrain_map.get_used_cells():
		## generate terrain tile index
		var editor_tile_idx = editor_terrain_map.get_cellv(hex_cell)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = GameData.get_terrain(terrain_id)

		var tile_id = RandomUtils.get_random_item(terrain_info.tile_ids.keys())
		var terrain_tile_idx = terrain_tileset.find_tile_by_name(tile_id)
		terrain_indexes[hex_cell] = terrain_tile_idx
		
		## generate terrain hex overlay
		var scatter_seed = hash(hex_cell) ^ source_map.map_seed
		var spawner = ScatterSpawner.new(terrain_id, scatter_seed)
		scatter_spawners[hex_cell] = spawner

func _generate_structures(struct_map):
	var struct_set = struct_map.get_tileset()
	for cell_pos in struct_map.get_used_cells():
		var index = struct_map.get_cellv(cell_pos)
		var struct_id = struct_set.tile_get_name(index)
		var struct_info = GameData.get_structure_info(struct_id)
		
		var struct = Structure.instance()
		struct.name = "%s_0" % struct_id
		struct.set_structure_info(struct_info)
		structures[cell_pos] = struct

func _extract_elevation(elevation_map):
	var elevation_tileset = elevation_map.get_tileset()
	for hex_cell in elevation_map.get_used_cells():
		var idx = elevation_map.get_cellv(hex_cell)
		var raw_str = elevation_tileset.tile_get_name(idx)
		var elevation = raw_str.split("=", true, 1)[1].to_float()
		terrain_elevation[hex_cell] = elevation
