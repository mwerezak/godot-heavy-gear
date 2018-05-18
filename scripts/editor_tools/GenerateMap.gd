## Generates nodes used in the WorldMap from an EditorMap

tool
extends EditorScript

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")
var TerrainTypes = preload("res://scripts/game/TerrainDefs.gd").new()

const TerrainOverlay = preload("res://scripts/terrain/TerrainOverlay.tscn")
const Structure = preload("res://scripts/structures/Structure.tscn")

const terrain_tileset = preload("res://tilesets/TerrainTiles.tres")

var map_root
var export_node

func _run():
	map_root = get_scene()
	
	export_node = Node2D.new()
	export_node.name = "Export"
	
	map_root.add_child(export_node)
	export_node.set_owner(get_editor_interface().get_edited_scene_root())
	
	print("map seed is... ", map_root.map_seed)
	
	print("generating terrain...")
	generate_terrain()
	
	print("generating structures...")
	generate_structures()

func generate_terrain():
	var editor_map = map_root.get_node("Terrain")
	var editor_tileset = editor_map.get_tileset()
	
	var terrain_map = _create_terrain_tilemap()
	export_node.add_child(terrain_map)
	terrain_map.set_owner(get_editor_interface().get_edited_scene_root())

	for hex_pos in editor_map.get_used_cells():
		var editor_tile_idx = editor_map.get_cellv(hex_pos)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = TerrainTypes.INFO[terrain_id]

		var tile_id = RandomUtils.get_random_item(terrain_info.tile_ids.keys())
		var terrain_tile_idx = terrain_tileset.find_tile_by_name(tile_id)
		print(hex_pos, ": ", terrain_id, "->", tile_id)
		terrain_map.set_cellv(hex_pos, terrain_tile_idx)

		## create terrain overlay
		var hex_size = Vector2(WorldMap.TERRAIN_WIDTH, WorldMap.TERRAIN_HEIGHT*3/4)
		var hex_center = terrain_map.map_to_world(hex_pos) + hex_size/2

		var overlay = TerrainOverlay.instance()
		overlay.name = "Overlay (%d, %d)"% [ hex_pos.x, hex_pos.y ]
		overlay.terrain_id = terrain_id
		overlay.scatter_seed = hash(hex_pos) ^ map_root.map_seed
		overlay.terrain_hex = hex_pos

		terrain_map.add_child(overlay)
		overlay.set_owner(get_editor_interface().get_edited_scene_root())

func _create_terrain_tilemap():
	var tilemap = TileMap.new()
	tilemap.name = "TerrainTiles"
	tilemap.tile_set = terrain_tileset
	tilemap.cell_size = _get_terrain_cell_size()
	tilemap.cell_half_offset = TileMap.HALF_OFFSET_X
	tilemap.cell_tile_origin = TileMap.TILE_ORIGIN_TOP_LEFT
	tilemap.cell_y_sort = true
	return tilemap

func _get_terrain_cell_size():
	return Vector2(WorldMap.TERRAIN_WIDTH, WorldMap.TERRAIN_HEIGHT*3/4)

func generate_structures():
	var struct_map = map_root.get_node("Structures")
	var struct_set = struct_map.get_tileset()
	
	var container = Node.new()
	container.name = "Structures"
	export_node.add_child(container)
	container.set_owner(get_editor_interface().get_edited_scene_root())

	for cell_pos in struct_map.get_used_cells():
		var index = struct_map.get_cellv(cell_pos)
		var struct_id = struct_set.tile_get_name(index)
		
		var struct = Structure.instance()
		struct.name = "%s_0" % struct_id
		struct.structure_id = struct_id
		struct.position = struct_map.map_to_world(cell_pos) + Vector2(WorldMap.UNITGRID_WIDTH/2, 0)
		
		container.add_child(struct)
		struct.set_owner(get_editor_interface().get_edited_scene_root())
