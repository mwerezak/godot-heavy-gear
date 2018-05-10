extends Sprite

onready var world = $"../WorldMap"
onready var tiles = $"../WorldMap/TerrainTiles"

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		global_position = world.get_global_mouse_position()
		_snap_to_grid()

func _snap_to_grid():
	var map_pos = tiles.world_to_map(global_position)
	#print(tiles.get_cellv(map_pos))
	global_position = tiles.map_to_world(map_pos)