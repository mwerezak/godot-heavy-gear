## Returns a dictionary { move_unit, move_cell, move_info }

extends "ContextBase.gd"

const MovementPathing = preload("res://scripts/units/MovementPathing.gd")

signal move_selected(move_unit, move_cell, move_info)

const HELP_TEXT = "Select a location to move to."
const CONFIRM_TEXT = "Select a location to move to (or double-click to confirm)."

onready var move_button = $MarginContainer/HBoxContainer/MoveButton
onready var label = $MarginContainer/HBoxContainer/Label
onready var move_display = $MovementDisplay

var move_unit = null
var move_pos = null
var possible_moves = null

func _init():
	load_properties = {
		move_unit = REQUIRED,
	}

func _ready():
	call_deferred("_ready_deferred")

func _ready_deferred():
	var world_map = get_tree().get_current_scene().world_map
	
	move_display.set_world_map(world_map)
	move_display.hide()
	remove_child(move_display)
	world_map.add_child(move_display)

func _setup():
	var pathing = MovementPathing.new(move_unit)
	possible_moves = pathing.possible_moves
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
	assert( possible_moves[move_pos].last_pos() == move_pos )
	context_return({
		move_unit = move_unit,
		move_info = possible_moves[move_pos],
	})

func cancel_move():
	context_return()

func _move_button_pressed(): finalize_move()

func _cancel_button_pressed(): cancel_move()

