extends "ContextBase.gd"

const UnitActivation = preload("res://scripts/units/UnitActivation.gd")

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var rotate_button = $MarginContainer/HBoxContainer/RotateButton

var active_unit
var current_activation

func activated(args):
	active_unit = args.unit
	current_activation = UnitActivation.new(active_unit)
	active_unit.current_activation = current_activation	
	.activated(args)

func resumed():
	.resumed()
	if _is_turn_over():
		context_manager.deactivate()

func _become_active():
	._become_active()
	move_button.disabled = !_can_move()
	rotate_button.disabled = !_can_rotate()

func deactivated():
	.deactivated()
	active_unit = null

func unit_cell_input(map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		if cell_pos == active_unit.cell_position && _can_move():
			_move_button_pressed()


func _can_move(): return current_activation.can_move()
func _can_rotate(): return current_activation.can_rotate()

func _is_turn_over():
	return !(_can_move() || _can_rotate() || current_activation.action_points > 0)

func _move_button_pressed():
	context_manager.activate("move_unit", { unit = active_unit })

func _rotate_button_pressed():
	context_manager.activate("select_facing", { unit = active_unit })

func _done_button_pressed():
	context_manager.deactivate()
