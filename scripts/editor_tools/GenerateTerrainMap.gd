## Randomizes the terrain tile appearances when run on a WorldMap scene

tool
extends EditorScript

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")

var TerrainTypes = preload("res://scripts/game/TerrainTypes.gd").new()

func _run():
	var tileset_id = "default" #TODO
	
	var editor_map = get_scene().find_node("EditorTerrain")
	var terrain_map = get_scene().find_node("TerrainTiles")
	
	var tileset_info = TerrainTypes.TILESETS[tileset_id]
	
	var editor_tileset = editor_map.get_tileset()
	var terrain_tileset = tileset_info.tileset
	terrain_map.set_tileset(terrain_tileset)
	
	for cell_pos in editor_map.get_used_cells():
		var editor_tile_idx = editor_map.get_cellv(cell_pos)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = tileset_info.terrain_types[terrain_id]
		
		var tile_id = RandomUtils.get_random_item(terrain_info.tile_ids)
		var terrain_tile_idx = terrain_tileset.find_tile_by_name(tile_id)
		print(cell_pos, ": ", terrain_id, "->", tile_id)
		terrain_map.set_cellv(cell_pos, terrain_tile_idx)
