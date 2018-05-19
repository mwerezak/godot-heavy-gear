## Generates the structures tileset used for map editing

tool
extends EditorScript

const WorldMap = preload("res://scripts/WorldMap.gd")
var StructureDefs = preload("res://scripts/game/StructureDefs.gd").new()

func _run():
	var tileset = get_scene()
	if tileset.name != "EditorStructures": return #sanity check
	
	for struct_id in StructureDefs.INFO:
		var struct_info = StructureDefs.INFO[struct_id]
		
		var tileset_entry = Sprite.new()
		print(struct_id)
		tileset_entry.name = struct_id
		tileset_entry.texture = struct_info.texture
		tileset_entry.centered = false
		tileset_entry.offset = Vector2(0, -struct_info.texture.get_size().y) + struct_info.position_offset
		tileset.add_child(tileset_entry)
		
		tileset_entry.set_owner(get_editor_interface().get_edited_scene_root())
