extends Node2D

signal mouse_entered
signal mouse_exited

var has_mouse = false
var footprint setget set_footprint_radius, get_footprint_radius

onready var mouse_catcher = $MouseCatcher/CollisionShape2D
onready var base_footprint = $BaseFootprint
onready var facing_marker = $Facing
onready var icon_sprite = $Icon
onready var direction_arcs = $DirectionArcs

func _on_mouse_entered():
	has_mouse = true
	emit_signal("mouse_entered")

func _on_mouse_exited():
	has_mouse = false
	emit_signal("mouse_exited")

## sets the size of the map marker in pixels
func set_footprint_radius(pixels):
	mouse_catcher.shape.radius = pixels
	base_footprint.radius = pixels
	
	var icon_radius = icon_radius()
	facing_marker.offset.x = max(pixels, icon_radius) + 8

func get_footprint_radius():
	return base_footprint.radius

## tries to get the radius of the smallest circle enclosing the icon sprite
func icon_radius():
	var size = icon_sprite.texture.get_size()
	size = icon_sprite.transform.basis_xform(size)/2
	return size.length()

## sets the direction of the facing marker
func set_facing(radians):
	facing_marker.rotation = radians

func set_facing_marker_visible(show_marker):
	if show_marker:
		facing_marker.show()
	else:
		facing_marker.hide()
