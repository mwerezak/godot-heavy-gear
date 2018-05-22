extends Sprite

const Constants = preload("res://scripts/Constants.gd")


const INTENSITY = 0.1
const OVERLAY_TEXTURE = preload("res://icons/terrain/elevation_overlay.png")
const ELEVATION_OVERLAY_MAT = preload("res://icons/terrain/elevation_overlay_material.tres")
const DEPTH_OVERLAY_MAT = preload("res://icons/terrain/depth_overlay_material.tres")

var level = 0 setget set_level

func _ready():
	z_as_relative = false
	z_index = Constants.GROUND_SCATTER_ZLAYER
	texture = OVERLAY_TEXTURE

func set_level(new_level):
	level = new_level
	if level == 0:
		self_modulate = Color(0,0,0,0)
	else:
		var intensity = abs(level) * INTENSITY
		self_modulate = Color(intensity, intensity, intensity, 1)
		if level >= 0:
			material = ELEVATION_OVERLAY_MAT
		else:
			material = DEPTH_OVERLAY_MAT