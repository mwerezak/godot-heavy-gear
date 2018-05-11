extends Node2D

signal mouse_entered
signal mouse_exited

var has_mouse = false

onready var mouse_catcher = $MouseCatcher/CollisionShape2D

func _on_mouse_entered():
	has_mouse = true
	emit_signal("mouse_entered")

func _on_mouse_exited():
	has_mouse = false
	emit_signal("mouse_exited")

## sets the size of the map marker in pixels
func set_footprint_radius(pixels):
	mouse_catcher.shape.radius = pixels
