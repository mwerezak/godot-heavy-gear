extends Sprite

const Constants = preload("res://scripts/Constants.gd")

var scroll_velocity
var display_rect setget set_display_rect

func _ready():
	centered = false
	region_enabled = true
	z_as_relative = false
	z_index = Constants.CLOUDS_ZLAYER
	
	texture = preload("res://icons/terrain/scrolling_clouds.png")
	modulate = Color("#07ffffff")
	material = preload("res://icons/terrain/scrolling_clouds_material.tres")
	scale = 3*Vector2(1,1)

func randomize_scroll():
	var scroll_angle = deg2rad(rand_range(0.0, 360.0))
	var scroll_speed = rand_range(2.5, 5.0) 
	scroll_velocity = scroll_speed*Vector2(cos(scroll_angle), sin(scroll_angle))

func set_display_rect(rect):
	display_rect = rect
	position = rect.position
	region_rect = Rect2(Vector2(), rect.size/scale)
	set_process(true)

func _process(delta):
	if !display_rect:
		set_process(false)
	else:
		region_rect.position += delta*scroll_velocity
