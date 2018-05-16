## Centers the terrain hexes in their cells, when run on a tileset scene

tool
extends EditorScript

const WorldMap = preload("res://scripts/WorldMap.gd")

func _run():
	var tileset = get_scene()
	
	for child in tileset.get_children():
		if child is Sprite:
			child.centered = false
			child.offset = Vector2(0, -WorldMap.TERRAIN_HEIGHT/8)