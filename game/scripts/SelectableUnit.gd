extends Node2D

var has_mouse = false

func collider_mouse_entered():
	has_mouse = true

func collider_mouse_exited():
	has_mouse = false



onready var selected = $SelectedMarker

func show_selected_marker(modulate=null):
	selected.modulate = modulate if modulate else Color(1,1,1,1)
	selected.show()
	
func hide_selected_marker():
	selected.hide()