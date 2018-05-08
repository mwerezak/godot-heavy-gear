extends Node2D

var has_mouse = false

func collider_mouse_entered():
	has_mouse = true

func collider_mouse_exited():
	has_mouse = false
