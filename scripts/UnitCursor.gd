extends Sprite

onready var world = $".."

var grid_position setget set_grid_position, get_grid_position

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = world.get_global_mouse_position()
		
		## don't snap to blank hexes
		if world.point_on_map(mouse_pos):
			var grid_pos = world.unit_grid.world_to_map(mouse_pos)
			set_grid_position(grid_pos)

func set_grid_position(cell):
	grid_position = cell
	global_position = world.unit_grid.map_to_world(cell)

func get_grid_position():
	return grid_position