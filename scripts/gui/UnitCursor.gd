extends Sprite

const Constants = preload("res://scripts/Constants.gd")

onready var world_map = get_parent()

var grid_position setget set_grid_position, get_grid_position

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = world_map.get_global_mouse_position()
		var grid_pos = world_map.get_grid_cell(mouse_pos)
		if world_map.grid_cell_on_map(grid_pos):
			set_grid_position(grid_pos)

func set_grid_position(cell):
	grid_position = cell
	global_position = world_map.get_grid_pos(cell)

func get_grid_position():
	return grid_position