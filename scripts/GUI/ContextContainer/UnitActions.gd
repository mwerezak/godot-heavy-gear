extends "ContextBase.gd"

const UnitActivation = preload("res://scripts/Units/UnitActivation.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var rotate_button = $MarginContainer/HBoxContainer/RotateButton

var active_unit
var current_activation

func activated(args):
	active_unit = args.unit
	current_activation = UnitActivation.new(active_unit)
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
	current_activation = null

func unit_cell_input(map, cell_pos, event):
	if cell_pos == active_unit.cell_position && event.is_action_pressed("click_select"):
		if _can_move():
			_move_button_pressed()

func _can_move():
	var partial = floor(current_activation.partial_moves/WorldMap.UNITGRID_SIZE)
	return current_activation.move_actions + partial > 0

func _can_rotate():
	return active_unit.has_facing() && current_activation.move_actions + current_activation.partial_turns > 0

func _is_turn_over():
	return !(_can_move() || _can_rotate() || current_activation.action_points > 0)

func _rotate_button_pressed():
	pass # replace with function body

func _move_button_pressed():
	context_manager.activate("move_unit", { unit = active_unit, current_activation = current_activation })

func _done_button_pressed():
	context_manager.deactivate()
