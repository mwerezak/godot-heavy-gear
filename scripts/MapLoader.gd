extends Reference

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const TerrainOverlay = preload("res://scripts/terrain/TerrainOverlay.tscn")
const Structure = preload("res://scripts/structures/Structure.tscn")

var world_map
var source_map

var terrain_indexes = {}
var terrain_overlays = {}
var structures = {}

func _init(world_map):
	self.world_map = world_map

func load_map(map_scene):
	source_map = map_scene.instance()
	var editor_map = source_map.get_node("Terrain")
	_generate_terrain(editor_map)
	
	var struct_map = source_map.get_node("Structures")
	_generate_structures(struct_map)

## rebuild cached terrain indexes and overlays
func _generate_terrain(editor_terrain_map):
	var editor_tileset = editor_terrain_map.get_tileset()
	var world_tileset = world_map.terrain.get_tileset()
	
	rand_seed(source_map.map_seed) #initialize seed
	
	terrain_overlays.clear()
	terrain_indexes.clear()
	for hex_pos in editor_terrain_map.get_used_cells():
		## generate terrain tile index
		var editor_tile_idx = editor_terrain_map.get_cellv(hex_pos)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = TerrainDefs.INFO[terrain_id]

		var tile_id = RandomUtils.get_random_item(terrain_info.tile_ids.keys())
		var terrain_tile_idx = world_tileset.find_tile_by_name(tile_id)
		terrain_indexes[hex_pos] = terrain_tile_idx
		
		## generate terrain hex overlay
		var overlay = TerrainOverlay.instance()
		overlay.name = "Overlay (%d, %d)"% [ hex_pos.x, hex_pos.y ]
		overlay.terrain_id = terrain_id
		overlay.scatter_seed = hash(hex_pos) ^ source_map.map_seed
		overlay.terrain_hex = hex_pos
		terrain_overlays[hex_pos] = overlay

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
