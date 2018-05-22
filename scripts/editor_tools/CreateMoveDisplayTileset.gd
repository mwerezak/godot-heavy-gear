## Generates terrain tiles from terrain definitions

tool
extends EditorScript

const WorldMap = preload("res://scripts/WorldMap.gd")

const TILES = {
	Blue = Color("#4ef6ff"),
	Yellow = Color("#fff232"),
	Red = Color("#ff6262"),
}

func _run():
	var tileset = get_scene()
	if tileset.name != "MovementTiles": return #sanity check
	
	for tile_id in TILES:
		print(tile_id)
		var tileset_entry = Sprite.new()
		tileset_entry.name = tile_id
		tileset_entry.texture = load("res://icons/movement_tile.png")
		tileset_entry.modulate = TILES[tile_id]
		tileset_entry.centered = false
		tileset_entry.offset = Vector2(0, -WorldMap.UNITGRID_HEIGHT/8)
		tileset.add_child(tileset_entry)
		
		tileset_entry.set_owner(get_editor_interface().get_edited_scene_root())
