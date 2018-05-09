extends "UIContextBase.gd"

onready var move_button = $MarginContainer/HBoxContainer/MoveButton

var move_marker = null

var selection = null
var move_unit = null
var move_pos = null

func activated(args):
	.activated(args)
	selection = args.selection
	move_unit = selection.selected.front()

func deactivated():
	.deactivated()
	selection.cleanup()
	move_button.disabled = true
	if move_marker:
		move_marker.hide()
		move_marker = null

func position_input(map, position, event):
	if event.is_action_pressed("click_select"):
		move_button.disabled = false
		if !move_marker: 
			move_marker = map.move_marker
			move_marker.show()
		move_marker.global_position = position
		
		#var confirm_move = (move_pos - position).length() < 16 if move_pos else false
		move_pos = position
		#if confirm_move: _move_button_pressed()

func _move_button_pressed():
	move_unit.global_position = move_pos
	context_manager.deactivate()
