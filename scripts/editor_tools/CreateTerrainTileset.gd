## Generates terrain tiles from terrain definitions

tool
extends EditorScript

const WorldMap = preload("res://scripts/WorldMap.gd")
var TerrainDefs = preload("res://scripts/game/TerrainDefs.gd").new()

func _run():
	var tileset = get_scene()
	
	for terrain_id in TerrainDefs.INFO:
		var terrain_info = TerrainDefs.INFO[terrain_id]
		for tile_id in terrain_info.tile_ids:
			var tile_texture = terrain_info.tile_ids[tile_id]
		
			print(tile_id)
			var tileset_entry = Sprite.new()
			tileset_entry.name = tile_id
			tileset_entry.texture = tile_texture
			tileset_entry.centered = false
			tileset_entry.offset = Vector2(0, -WorldMap.TERRAIN_HEIGHT/8)
			tileset.add_child(tileset_entry)
			
			tileset_entry.set_owner(get_editor_interface().get_edited_scene_root())
