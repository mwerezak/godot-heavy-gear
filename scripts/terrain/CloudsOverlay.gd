extends Sprite

const Constants = preload("res://scripts/Constants.gd")

var drift_velocity
var display_rect setget set_display_rect

func _ready():
	centered = false
	region_enabled = true
	z_as_relative = false
	z_index = Constants.CLOUDS_ZLAYER

	material = preload("res://icons/terrain/scrolling_clouds_material.tres")
	modulate = Color("#07ffffff")

func set_display_rect(rect):
	display_rect = rect
	position = rect.position
	region_rect = Rect2(Vector2(), rect.size/scale)
	set_process(true)

func _process(delta):
	if !display_rect:
		set_process(false)
	else:
		region_rect.position += delta*drift_velocity