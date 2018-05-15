extends "ContextBase.gd"

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var label = $MarginContainer/HBoxContainer/Label
onready var move_display = get_tree().get_root().find_node("MovementDisplay", true, false)

var selected_markers = null
var move_unit = null
var move_pos = null
var move_info = null
var possible_moves = null

func activated(args):
	.activated(args)
	selected_markers = args.selected_markers
	var move_marker = selected_markers.selected.front()
	move_unit = move_marker.get_parent()
	possible_moves = move_display.setup(move_unit)
	label.text = "Select a location to move to."

func deactivated():
	.deactivated()
	selected_markers.cleanup()
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
			move_button.disabled = true
			move_display.clear_move_marker()
			move_pos = null
			label.text = "Select a location to move to."
		else:
			if move_pos == cell_pos:
				_move_button_pressed()
			else:
				move_button.disabled = false
				move_display.place_move_marker(possible_moves, cell_pos)
				move_pos = cell_pos
				move_info = possible_moves[move_pos]
				label.text = "Select a location to move to (or click again to confirm)."

func _move_button_pressed():
	move_unit.cell_position = move_pos
	if move_info.facing != null:
		move_unit.set_facing(move_info.facing)
	context_manager.deactivate()
	
	if move_unit.has_facing() && (move_info.movement_mode.free_rotate || move_info.turns_remaining > 0):
		context_manager.activate("select_facing", { rotate_unit = move_unit, max_turns = move_info.turns_remaining })
