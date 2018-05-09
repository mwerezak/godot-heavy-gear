extends Node2D

signal mouse_entered
signal mouse_exited

var has_mouse = false

func _collider_mouse_entered():
	has_mouse = true
	emit_signal("mouse_entered")

func _collider_mouse_exited():
	has_mouse = false
	emit_signal("mouse_exited")



## TODO - this sucks

onready var selected = $SelectedMarker

func show_selected_marker(modulate=null):
	selected.modulate = modulate if modulate else Color(1,1,1,1)
	selected.show()
	
func hide_selected_marker():
	selected.hide()