## Randomizes the terrain tile appearances when run on a WorldMap scene

tool
extends EditorScript

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")
const TerrainOverlay = preload("res://scripts/terrain/TerrainOverlay.tscn")

var TerrainTypes = preload("res://scripts/game/TerrainTypes.gd").new()

func _run():
	var scatter_seed = randi()
	print("scatter seed is... ", scatter_seed)
	var editor_map = get_scene().find_node("EditorTerrain")
	var terrain_map = get_scene().find_node("TerrainTiles")
	
	#clear overlays
	for child in terrain_map.get_children():
		terrain_map.remove_child(child)
	
	var editor_tileset = editor_map.get_tileset()
	var terrain_tileset = terrain_map.get_tileset()
	
	for cell_pos in editor_map.get_used_cells():
		var editor_tile_idx = editor_map.get_cellv(cell_pos)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = TerrainTypes.INFO[terrain_id]
		
		var tile_id = RandomUtils.get_random_item(terrain_info.tile_ids)
		var terrain_tile_idx = terrain_tileset.find_tile_by_name(tile_id)
		print(cell_pos, ": ", terrain_id, "->", tile_id)
		terrain_map.set_cellv(cell_pos, terrain_tile_idx)
		
		## create terrain overlays
		var hex_size = Vector2(WorldMap.TERRAIN_WIDTH, WorldMap.TERRAIN_HEIGHT*3/4)
		var hex_center = terrain_map.map_to_world(cell_pos) + hex_size/2
		
		var overlay = TerrainOverlay.instance()
		overlay.terrain_id = terrain_id
		overlay.scatter_seed = hash(cell_pos) ^ scatter_seed
		overlay.position = hex_center
		terrain_map.add_child(overlay)
		overlay.set_owner(get_editor_interface().get_edited_scene_root())

