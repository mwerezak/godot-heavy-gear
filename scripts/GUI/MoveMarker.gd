## A marker that shows the destination for a move as well as the 
## possible directions the unit will be able to face afterwards.

extends Sprite

const HexUtils = preload("res://scripts/HexUtils.gd")

onready var facing_marker0 = $Facing0
onready var facing_markers = { 0: [ facing_marker0 ] }

func _ready():
	for arc in range(1, 6):
		facing_markers[arc] = []
		for i in [-1, 1]:
			var facing_marker = facing_marker0.duplicate(0)
			facing_marker.rotation = HexUtils.UNIT_ARC*arc*i
			facing_markers[arc].append(facing_marker)
			add_child(facing_marker)

	hide_facing_arc()

func show_facing_arc(facing, turn_arc):
	if turn_arc >= 6:
		rotation = 0
		hide_facing_arc()
	else:
		rotation = HexUtils.dir2rad(facing)
		for arc in facing_markers:
			for facing_marker in facing_markers[arc]:
				if arc <= turn_arc:
					facing_marker.show()
				else:
					facing_marker.hide()

func hide_facing_arc():
	for arc in facing_markers:
		for facing_marker in facing_markers[arc]:
			facing_marker.hide()
