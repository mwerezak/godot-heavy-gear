extends Sprite

const Constants = preload("res://scripts/Constants.gd")


var scroll_velocity
var display_rect setget set_display_rect

func _ready():
	var scroll_dir = Vector2(rand_range(-5, 5), rand_range(-1, 1)).normalized()
	scroll_velocity = 5.0*scroll_dir
	
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