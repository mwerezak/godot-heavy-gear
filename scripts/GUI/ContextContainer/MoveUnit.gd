extends "ContextBase.gd"

const MovementPathing = preload("res://scripts/Units/MovementPathing.gd")

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var label = $MarginContainer/HBoxContainer/Label
onready var move_display = get_tree().get_root().find_node("MovementDisplay", true, false)

var move_unit = null
var current_activation = null
var move_pos = null
var possible_moves = null

func activated(args):
	.activated(args)
	move_unit = args.unit
	current_activation = args.current_activation
	
	var world_map = move_unit.get_parent()
	possible_moves = MovementPathing.calculate_movement(world_map, move_unit, current_activation)
	
	move_display.show_movement(possible_moves, current_activation.move_actions)
	label.text = "Select a location to move to."

func deactivated():
	.deactivated()
	move_button.disabled = true

func _become_active():
	._become_active()
	move_button.grab_focus()
	move_display.show()

func _become_inactive():
	._become_inactive()
	move_display.hide()

func unit_cell_input(map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		if !possible_moves.has(cell_pos):
			_cancel_button_pressed() #double click outside possible moves to cancel
		else:
			if move_pos == cell_pos:
				_move_button_pressed()
			else:
				move_button.disabled = false
				move_display.place_move_marker(possible_moves, cell_pos)
				move_pos = cell_pos
				label.text = "Select a location to move to (or click again to confirm)."

func _reset():
	move_button.disabled = true
	move_display.clear_move_marker()
	label.text = "Select a location to move to."

func _move_button_pressed():
	var move_info = possible_moves[move_pos]
	
	current_activation.move_unit(move_pos, move_info)
	
	if move_info.facing != null:
		move_unit.set_facing(move_info.facing)
	context_manager.deactivate()
	
	#if move_unit.has_facing() && (move_info.movement_mode.free_rotate || move_info.turns_remaining > 0):
	#	context_manager.activate("select_facing", { rotate_unit = move_unit, max_turns = move_info.turns_remaining })

func _cancel_button_pressed():
	context_manager.deactivate()
