extends Node2D

const Contstants = preload("res://scripts/Constants.gd")
const Distances = preload("res://scripts/Game/Distances.gd")

## mouse handling
onready var collider = $Collider

signal mouse_entered
signal mouse_exited

var has_mouse = false

func _collider_mouse_entered():
	has_mouse = true
	emit_signal("mouse_entered")

func _collider_mouse_exited():
	has_mouse = false
	emit_signal("mouse_exited")

## base footprint diameter
export(float) var base_size = 1.90

const FOOTPRINT_COLOR = Color(0.3, 0.3, 0.3, 0.5)

func _ready():
	z_as_relative = false
	z_index = Contstants.UNITS_ZLAYER
	
	## setup the mouse click area
	var footprint_shape = CircleShape2D.new()
	footprint_shape.radius = Distances.units2pixels(base_size/2)
	
	var collider_region = CollisionShape2D.new()
	collider_region.set_shape(footprint_shape)
	
	collider.add_child(collider_region)
	

	update()


## draw the base footprint
func _draw():
	_draw_circle(Vector2(), Distances.units2pixels(base_size/2), FOOTPRINT_COLOR)

## we use this instead of draw_circle() so that we can get anti-aliasing
func _draw_circle(center, radius, color, numpts=32):
	var points = PoolVector2Array()
	for i in numpts:
		var rad = i*deg2rad(360)/numpts
		var point = radius*Vector2(sin(rad), cos(rad))
		points.push_back(point)
	draw_colored_polygon(points, color, PoolVector2Array(), null, null, true)