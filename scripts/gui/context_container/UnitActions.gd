extends "ContextBase.gd"

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var rotate_button = $MarginContainer/HBoxContainer/RotateButton
onready var done_button = $MarginContainer/HBoxContainer/MarginContainer/DoneButton

var active_unit
var current_activation
var confirm_end_turn

func _init():
	load_properties = {
		active_unit = REQUIRED,
	}

func _setup():
	assert(active_unit.current_activation)
	current_activation = active_unit.current_activation

func resumed():
	.resumed()
	if _is_turn_over():
		context_manager.deactivate()

func _become_active():
	._become_active()
	move_button.disabled = !_can_move()
	rotate_button.disabled = !_can_rotate()

func _become_inactive():
	._become_inactive()
	done_button.text = "End Turn [Enter]"
	confirm_end_turn = false

func deactivated():
	.deactivated()
	active_unit = null
	current_activation = null

func cell_input(map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		if cell_pos == active_unit.cell_position:
			if _can_move():
				_move_button_pressed()
			elif _can_rotate():
				_rotate_button_pressed()


func _can_move(): return true#current_activation.can_move()
func _can_rotate(): return true#current_activation.can_rotate()

func _is_turn_over():
	return !(_can_move() || _can_rotate() || current_activation.action_points > 0)

func _move_button_pressed():
	if _can_move():
		var move_context = context_manager.activate("MoveUnit", { move_unit = active_unit })
		yield(move_context, "context_return")
		if _can_rotate():
			context_manager.activate("SelectFacing", { rotate_unit = active_unit })

func _rotate_button_pressed():
	if _can_rotate():
		context_manager.activate("SelectFacing", { rotate_unit = active_unit })

func _done_button_pressed():
	if confirm_end_turn:
		context_return()
	else:
		confirm_end_turn = true
		done_button.text = "Confirm? [Enter]"
