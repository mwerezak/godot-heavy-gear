extends "ContextBase.gd"

const MovementPathing = preload("res://scripts/units/MovementPathing.gd")

const HELP_TEXT = "Select a location to move to."
const CONFIRM_TEXT = "Select a location to move to (or click again to confirm)."

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var label = $MarginContainer/HBoxContainer/Label
onready var move_display = $"/root/Main/WorldMap/MovementDisplay"

var move_unit = null
var move_pos = null
var possible_moves = null

func activated(args):
	.activated(args)
	move_unit = args.unit
	
	possible_moves = MovementPathing.calculate_movement(move_unit)
	
	move_display.show_movement(possible_moves, move_unit.current_activation)
	label.text = HELP_TEXT

func deactivated():
	.deactivated()
	move_button.disabled = true
	move_pos = null

func _become_active():
	._become_active()
	move_button.grab_focus()
	move_display.show()

func _become_inactive():
	._become_inactive()
	move_display.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		cancel_move()
	if move_pos && (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select")):
		finalize_move()

func cell_input(map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		if !possible_moves.has(cell_pos) && event.doubleclick:
			cancel_move() #double click outside possible moves to cancel
		else:
			move_button.disabled = false
			move_display.place_move_marker(possible_moves, cell_pos)
			move_pos = cell_pos
			label.text = CONFIRM_TEXT
			
			if event.doubleclick:
				finalize_move()

func _reset():
	move_button.disabled = true
	move_display.clear_move_marker()
	label.text = HELP_TEXT

func finalize_move():
	var move_info = possible_moves[move_pos]
	move_unit.current_activation.move(move_pos, move_info)
	
	context_manager.deactivate()
	if move_unit.current_activation.can_rotate():
		context_manager.activate("select_facing", { unit = move_unit })

func cancel_move():
	context_manager.deactivate()
	if move_unit.current_activation.can_rotate():
		context_manager.activate("select_facing", { unit = move_unit })

func _move_button_pressed(): finalize_move()

func _cancel_button_pressed(): cancel_move()

