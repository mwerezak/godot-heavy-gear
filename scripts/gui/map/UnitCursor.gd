extends Sprite

const Constants = preload("res://scripts/Constants.gd")

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _unhandled_input(event):
	var map_view = get_node("../MapView")
	if !map_view: return
	
	if event is InputEventMouseMotion:
		var mouse_pos = map_view.get_global_mouse_position()
		if map_view.display_rect.has_point(mouse_pos):
			position = map_view.unit_grid.snap_to_grid(mouse_pos)

