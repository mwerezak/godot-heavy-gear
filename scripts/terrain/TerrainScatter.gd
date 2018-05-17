extends Sprite

var base_radius = 10 setget set_base_radius, get_base_radius

onready var footprint = $BaseFootprint
onready var footprint_shape = $BaseFootprint/CollisionShape2D

func set_base_radius(radius):
	footprint_shape.shape.radius = radius

func get_base_radius():
	return footprint_shape.shape.radius