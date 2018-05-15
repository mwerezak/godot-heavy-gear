extends "ContextBase.gd"

const UnitActivation = preload("res://scripts/Units/UnitActivation.gd")

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var rotate_button = $MarginContainer/HBoxContainer/RotateButton

var active_unit

func activated(args):
	active_unit = args.unit
	active_unit.current_activation = UnitActivation.new(active_unit)
	
	.activated(args)
	if _can_move():
		_move_button_pressed()

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
	if cell_pos == active_unit.cell_position && event.is_action_pressed("click_select"):
		if _can_move():
			_move_button_pressed()

func _can_move(): return active_unit.current_activation.can_move()
func _can_rotate(): return active_unit.current_activation.can_rotate()

func _is_turn_over():
	return !(_can_move() || _can_rotate() || active_unit.current_activation.action_points > 0)

func _move_button_pressed():
	context_manager.activate("move_unit", { unit = active_unit })

func _rotate_button_pressed():
	context_manager.activate("select_facing", { unit = active_unit })

func _done_button_pressed():
	context_manager.deactivate()
