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

var color = Color("#657e2a")
var brightness = 0 setget set_brightness

onready var label = $Label2D/PanelContainer/Label
onready var label_node = $Label2D

func _ready():
	z_as_relative = false
	z_index = Constants.ELEVATION_OVERLAY_ZLAYER
	
	label_node.z_as_relative = false
	label_node.z_index = Constants.HUD_ZLAYER

const _X_AXIS = Vector3(1, 0, 0)
const _Y_AXIS = Vector3(0, 1, 0)
const _Z_AXIS = Vector3(0, 0, 1)
func setup(elevation_info):
	position = Vector2(elevation_info.world_pos.x, elevation_info.world_pos.y)
	
	var lighting = _X_AXIS.rotated(_Y_AXIS, LIGHT_PITCH).rotated(_Z_AXIS, LIGHT_AZIMUTH)
	var normal_bright = lighting.dot(elevation_info.normal) - lighting.dot(_Z_AXIS)
	var total_bright = INTENSITY*( NORMAL_MULT*normal_bright + LEVEL_MULT*elevation_info.level)
	set_brightness(total_bright)

func set_brightness(value):
	var modulate_color = color
	modulate_color.a = abs(value)
	self_modulate = modulate_color
	material = ELEVATION_OVERLAY_MAT if value >= 0 else DEPTH_OVERLAY_MAT
	brightness = value

#func set_level(new_level):
#	level = new_level
#	if level == 0:
#		hide()
#	else:
#		show()
#		var intensity = abs(level) * INTENSITY
#		var c = Color("#657e2a")
#		c.a = intensity
#		self_modulate = c 
#		if level >= 0:
#			material = ELEVATION_OVERLAY_MAT
#		else:
#			material = DEPTH_OVERLAY_MAT
#
#		var height = level*HexUtils.UNIT_METRE
#		if abs(height) >= 0.1:
#			label.text = "%+0.1fm" % height ##todo distance formatting helpers

func toggle_labels():
	label_node.visible = !label_node.visible