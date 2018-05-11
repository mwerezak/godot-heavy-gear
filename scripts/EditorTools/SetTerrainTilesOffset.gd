## This script is intended to be run on a tileset scene
## Centers the terrain hexes in their cells

tool
extends EditorScript

## copied from WorldMap.gd
const TERRAIN_HEIGHT = 74*4 #296

func _run():
	var tileset = get_scene()
	
	for child in tileset.get_children():
		if child is Sprite:
			child.centered = false
			child.offset = Vector2(0, -TERRAIN_HEIGHT/8)