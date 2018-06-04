extends Sprite

const Constants = preload("res://scripts/Constants.gd")


var scroll_velocity
var display_rect setget set_display_rect

func _ready():
	var scroll_dir = Vector2(rand_range(-3, 3), rand_range(-1, 1)).normalized()
	var scroll_speed = rand_range(2.5, 7.5) 
	scroll_velocity = scroll_speed*scroll_dir
	
	region_enabled = true
	z_as_relative = false
	z_index = Constants.CLOUDS_ZLAYER

func set_display_rect(rect):
	display_rect = rect
	position = rect.position
	region_rect = Rect2(Vector2(), rect.size)
	set_process(true)

func _process(delta):
	if !display_rect:
		set_process(false)
	else:
		region_rect.position += delta*scroll_velocity