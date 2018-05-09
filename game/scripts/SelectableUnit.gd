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
