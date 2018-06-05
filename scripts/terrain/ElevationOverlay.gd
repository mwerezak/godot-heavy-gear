extends Sprite

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

const ELEVATION_OVERLAY_MAT = preload("res://icons/terrain/elevation_overlay_material.tres")
const DEPTH_OVERLAY_MAT = preload("res://icons/terrain/depth_overlay_material.tres")

const LIGHT_AZIMUTH = deg2rad(150)
const LIGHT_PITCH = deg2rad(60)
const INTENSITY = 1.0
const NORMAL_MULT = 1.0
const LEVEL_MULT = 0.125

var color = Color("#ffffff") setget set_color
var brightness = 0 setget set_brightness

func _ready():
	z_as_relative = false
	z_index = Constants.ELEVATION_OVERLAY_ZLAYER

const _X_AXIS = Vector3(1, 0, 0)
const _Y_AXIS = Vector3(0, 1, 0)
const _Z_AXIS = Vector3(0, 0, 1)
func setup(elevation_info):
	position = elevation_info.world_pos
	
	var lighting = _X_AXIS.rotated(_Y_AXIS, LIGHT_PITCH).rotated(_Z_AXIS, LIGHT_AZIMUTH)
	var normal_bright = lighting.dot(elevation_info.normal) - lighting.dot(_Z_AXIS)
	var total_bright = INTENSITY*( NORMAL_MULT*normal_bright + LEVEL_MULT*elevation_info.level)
	set_brightness(total_bright)

func set_color(new_color):
	if color != new_color:
		color = new_color
		set_brightness(brightness)

func set_brightness(value):
	brightness = value
	if brightness == 0:
		hide()
	else:
		var modulate_color = color
		modulate_color.a = abs(value)
		self_modulate = modulate_color
		material = ELEVATION_OVERLAY_MAT if value >= 0 else DEPTH_OVERLAY_MAT
		show()
