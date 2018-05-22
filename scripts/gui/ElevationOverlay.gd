extends Sprite

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

const INTENSITY = 0.1
const ELEVATION_OVERLAY_MAT = preload("res://icons/terrain/elevation_overlay_material.tres")
const DEPTH_OVERLAY_MAT = preload("res://icons/terrain/depth_overlay_material.tres")

var level setget set_level

onready var label = $Label2D/PanelContainer/Label
onready var label_node = $Label2D

func _ready():
	z_as_relative = false
	z_index = Constants.GROUND_SCATTER_ZLAYER
	
	label_node.z_as_relative = false
	label_node.z_index = Constants.HUD_ZLAYER

func set_level(new_level):
	level = new_level
	if level == 0:
		self_modulate = Color(0,0,0,0)
		label_node.hide()
	else:
		var intensity = abs(level) * INTENSITY
		self_modulate = Color(intensity, intensity, intensity, 1)
		if level >= 0:
			material = ELEVATION_OVERLAY_MAT
		else:
			material = DEPTH_OVERLAY_MAT
		
		var height = level*HexUtils.UNIT_METRE
		if abs(height) >= 0.1:
			label.text = "%+0.1fm" % height ##todo distance formatting helpers
			label_node.show()
		else:
			label_node.hide()
		