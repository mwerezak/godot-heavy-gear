extends Reference

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const ScatterSpawner = preload("res://scripts/terrain/ScatterSpawner.tscn")
const Structure = preload("res://scripts/structures/Structure.tscn")
const RoadBuilder = preload("res://scripts/terrain/RoadBuilder.gd")

var world_map
var source_map

var global_lighting
var terrain_indexes = {}
var terrain_elevation = {}
var scatter_spawners = {}
var structures = {}
var road_segments = []

func _init(world_map):
	self.world_map = world_map

func load_map(map_scene):
	source_map = map_scene.instance()
	
	global_lighting = source_map.global_lighting
	
	rand_seed(source_map.map_seed) #initialize seed
	
	var editor_map = source_map.get_node("Terrain")
	_generate_terrain(editor_map)
	
	var struct_map = source_map.get_node("Structures")
	_generate_structures(struct_map)
	
	## generate roads
	var road_map = source_map.get_node("Roads")
	var builder = RoadBuilder.new(world_map)
	road_segments = builder.build_segments(road_map)
	
	## extract elevation data
	var elevation_map = source_map.get_node("Elevation")
	_extract_elevation(elevation_map)

## rebuild cached terrain indexes and overlays
func _generate_terrain(editor_terrain_map):
	var editor_tileset = editor_terrain_map.get_tileset()
	var world_tileset = world_map.terrain.get_tileset()
	
	for hex_pos in editor_terrain_map.get_used_cells():
		## generate terrain tile index
		var editor_tile_idx = editor_terrain_map.get_cellv(hex_pos)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = TerrainDefs.INFO[terrain_id]

		var tile_id = RandomUtils.get_random_item(terrain_info.tile_ids.keys())
		var terrain_tile_idx = world_tileset.find_tile_by_name(tile_id)
		terrain_indexes[hex_pos] = terrain_tile_idx
		
		## generate terrain hex overlay
		var spawner = ScatterSpawner.instance()
		spawner.name = "Overlay (%d, %d)"% [ hex_pos.x, hex_pos.y ]
		spawner.terrain_id = terrain_id
		spawner.scatter_seed = hash(hex_pos) ^ source_map.map_seed
		scatter_spawners[hex_pos] = spawner

func _generate_structures(struct_map):
	var struct_set = struct_map.get_tileset()
	for cell_pos in struct_map.get_used_cells():
		var index = struct_map.get_cellv(cell_pos)
		var struct_id = struct_set.tile_get_name(index)
		var struct_info = StructureDefs.get_info(struct_id)
		
		var struct = Structure.instance()
		struct.name = "%s_0" % struct_id
		struct.set_structure_info(struct_info)
		struct.position = world_map.get_grid_pos(cell_pos)
		structures[cell_pos] = struct

func _extract_elevation(elevation_map):
	var elevation_tileset = elevation_map.get_tileset()
	for hex_pos in elevation_map.get_used_cells():
		var idx = elevation_map.get_cellv(hex_pos)
		var raw_str = elevation_tileset.tile_get_name(idx)
		var elevation = raw_str.split("=", true, 1)[1].to_float()
		terrain_elevation[hex_pos] = elevation
