tool
extends EditorScript

var TerrainTypes = preload("res://scripts/Game/TerrainTypes.gd").new()

func _run():
	var tilemap = get_scene().find_node("TerrainTiles")

	for cell_pos in tilemap.get_used_cells():
		var cur_tile = tilemap.get_cellv(cell_pos)
		var new_tile = randomize_tile_id(cur_tile)
		print(cur_tile, "->", new_tile)
		tilemap.set_cellv(cell_pos, new_tile)

func randomize_tile_id(tile_id):
	var terrain_info = TerrainTypes.get_tile_terrain_info(tile_id)
	
	if !terrain_info: return tile_id
	
	var rand_idx = randi() % terrain_info.tile_ids.size()
	return terrain_info.tile_ids[rand_idx]
