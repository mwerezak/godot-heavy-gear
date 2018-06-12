extends Sprite

const Constants = preload("res://scripts/Constants.gd")

export(Vector2) var drift_velocity = Vector2(0, 0)
export(Rect2) var display_rect setget set_display_rect

func _ready():
	centered = false
	region_enabled = true
	z_as_relative = false
	z_index = Constants.CLOUDS_ZLAYER
	
	texture = preload("res://icons/terrain/scrolling_clouds.png")
	modulate = Color("#07ffffff")
	material = preload("res://icons/terrain/scrolling_clouds_material.tres")
	scale = 3*Vector2(1,1)

func set_drift_velocity(drift):
	drift_velocity = drift
	set_process(true)

func set_display_rect(rect):
	display_rect = rect
	set_process(true)
	if rect:
		position = rect.position
		region_rect = Rect2(Vector2(), rect.size/scale)

func _process(delta):
	if display_rect && drift_velocity.length_squared() > 0:
		region_rect.position += delta*drift_velocity
	else:
		set_process(false)
