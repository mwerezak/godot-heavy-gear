## Generates terrain tiles from terrain definitions

tool
extends EditorScript

const WorldMap = preload("res://scripts/WorldMap.gd")

## this sucks, but I don't have a better idea
const LEVEL_RANGE = 5

const DEFAULT_TEXTURE = preload("res://icons/terrain/editor/elevation/notfound.png")

func _run():
	var tileset = get_scene()
	if tileset.name != "EditorElevation": return #sanity check
	
	var file_check = File.new()
	for level in range(-LEVEL_RANGE, LEVEL_RANGE+1):
		if level == 0: continue
		
		print("level %+d" % level)
		var texture_path = "res://icons/terrain/editor/elevation/level%+d.png" % level
		
		var texture = load(texture_path) if file_check.file_exists(texture_path) else DEFAULT_TEXTURE
		var alpha = abs(float(level)/LEVEL_RANGE)
		
		var tileset_entry = Sprite.new()
		tileset_entry.name = "level=%d" % level
		tileset_entry.texture = texture
		tileset_entry.modulate = Color(1, 1, 1, alpha)
		tileset_entry.centered = false
		tileset_entry.offset = Vector2(0, -WorldMap.TERRAIN_HEIGHT/8)
		tileset.add_child(tileset_entry)
		
		tileset_entry.set_owner(get_editor_interface().get_edited_scene_root())

