extends "ContextBase.gd"

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var move_display = get_tree().get_root().find_node("MovementDisplay", true, false)

#var move_marker = null

var selected_markers = null
var move_unit = null
var move_pos = null
var movement_calc = null

func activated(args):
	.activated(args)
	selected_markers = args.selected_markers
	var move_marker = selected_markers.selected.front()
	move_unit = move_marker.get_parent()
	movement_calc = move_display.setup(move_unit)

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
		move_button.disabled = false
		move_display.place_move_marker(movement_calc, cell_pos)
		
		#var confirm_move = (move_pos - position).length() < 16 if move_pos else false
		move_pos = cell_pos
		#if confirm_move: _move_button_pressed()

func _move_button_pressed():
	var new_facing = move_unit.get_parent().get_nearest_dir(move_unit.cell_position, move_pos)
	move_unit.set_facing(new_facing)
	move_unit.cell_position = move_pos
	context_manager.deactivate()
