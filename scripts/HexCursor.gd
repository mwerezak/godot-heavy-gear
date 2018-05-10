extends Sprite

onready var root = $".."

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		global_position = root.world.get_global_mouse_position()
		_snap_to_grid()

func _snap_to_grid():
	var tiles = root.world.terrain
	var map_pos = tiles.world_to_map(global_position)
	#print(tiles.get_cellv(map_pos))
	global_position = tiles.map_to_world(map_pos)