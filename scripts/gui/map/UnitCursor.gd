extends Sprite

const Constants = preload("res://scripts/Constants.gd")

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _unhandled_input(event):
	var world_map = get_tree().get_current_scene().world_map
	
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		if world_map && world_map.has_point(mouse_pos):
			position = world_map.unit_grid.snap_to_grid(mouse_pos)

