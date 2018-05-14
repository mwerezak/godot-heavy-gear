extends Node2D

const FOOTPRINT_RADIUS = 24 #pixels

signal mouse_entered
signal mouse_exited

var color setget set_color

var has_mouse = false

onready var mouse_catcher = $MouseCatcher/CollisionShape2D
onready var base_footprint = $BaseFootprint
onready var facing_marker = $Facing

onready var nato_counter = $NatoCounter

func _ready():
	set_footprint_radius(FOOTPRINT_RADIUS)

func _on_mouse_entered():
	has_mouse = true
	emit_signal("mouse_entered")

func _on_mouse_exited():
	has_mouse = false
	emit_signal("mouse_exited")

func set_color(c):
	color = c
	nato_counter.color = c

func set_nato_symbol(sym_id):
	nato_counter.symbol = sym_id

## sets the size of the map marker in pixels
func set_footprint_radius(pixels):
	mouse_catcher.shape.radius = pixels
	base_footprint.radius = pixels
	
	#var icon_radius = icon_radius()
	facing_marker.offset.x = pixels + 8

func get_footprint_radius():
	return base_footprint.radius

## tries to get the radius of the smallest circle enclosing the icon sprite
#func icon_radius():
#	var size = nato_counter.texture.get_size()
#	size = nato_counter.transform.basis_xform(size)/2
#	return size.length()

## sets the direction of the facing marker
func set_facing(radians):
	facing_marker.rotation = radians

func set_facing_marker_visible(show_marker):
	if show_marker:
		facing_marker.show()
	else:
		facing_marker.hide()
