extends Sprite

const Constants = preload("res://scripts/Constants.gd")

onready var world = $".."

var grid_position setget set_grid_position, get_grid_position

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = world.get_global_mouse_position()
		
		## don't snap to blank hexes
		if world.point_on_map(mouse_pos):
			var grid_pos = world.get_grid_cell(mouse_pos)
			set_grid_position(grid_pos)

func set_grid_position(cell):
	grid_position = cell
	global_position = world.get_grid_pos(cell)

func get_grid_position():
	return grid_position