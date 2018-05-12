extends "UIContextBase.gd"

onready var move_button = $MarginContainer/HBoxContainer/MoveButton

var move_marker = null

var selected_markers = null
var move_unit = null
var move_pos = null

func activated(args):
	.activated(args)
	selected_markers = args.selected_markers
	var move_marker = selected_markers.selected.front()
	move_unit = move_marker.get_parent()

func deactivated():
	.deactivated()
	selected_markers.cleanup()
	move_button.disabled = true
	if move_marker:
		move_marker.hide()
		move_marker = null

func _become_active():
	._become_active()
	move_button.grab_focus()

func unit_cell_input(map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		move_button.disabled = false
		if !move_marker: 
			move_marker = map.move_marker
			move_marker.show()
		move_marker.position = map.world.get_grid_pos(cell_pos)
		
		#var confirm_move = (move_pos - position).length() < 16 if move_pos else false
		move_pos = cell_pos
		#if confirm_move: _move_button_pressed()

func _move_button_pressed():
	var new_facing = move_unit.get_parent().get_nearest_dir(move_unit.cell_position, move_pos)
	move_unit.set_facing(new_facing)
	move_unit.cell_position = move_pos
	context_manager.deactivate()
