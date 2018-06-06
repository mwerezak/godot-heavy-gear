## Returns the selected units as an array.

extends "ContextBase.gd"

const SelectionMarker = preload("res://scripts/gui/map_markers/SelectionMarker.tscn")
const SelectionGroup = preload("res://scripts/gui/map_markers/SelectionGroup.gd")

export(Color) var hover_color = Color(0.7, 0.7, 0.7, 0.5)
export(Color) var selected_color = Color(0.35, 1.0, 0.35, 1.0)

var selection_group
var select_from

var select_text setget set_select_text
var confirm_text setget set_confirm_text
var button_text setget set_button_text, get_button_text

onready var label = $MarginContainer/HBoxContainer/Label
onready var select_button = $MarginContainer/HBoxContainer/SelectButton

func _init():
	load_properties = {
		select_from = null,
		select_text = "Select a unit.",
		confirm_text = "Select a unit (or double-click to confirm).",
		button_text = "Select",
	}

func _ready():
	hide()

func _setup():
	selection_group = SelectionGroup.new(SelectionMarker)
	if select_from:
		for unit in select_from:
			selection_group.mark_object(unit)

	set_selection([])

func _become_active():
	._become_active()
	select_button.grab_focus()

func deactivated():
	.deactivated()

func set_selection(new_selection):
	selection_group.set_selected(new_selection)
	select_button.disabled = !has_selection()
	_update_label()

func has_selection():
	return selection_group && !selection_group.get_selected().empty()

func set_select_text(text):
	select_text = text
	_update_label()

func set_confirm_text(text):
	confirm_text = text
	_update_label()

func _update_label():
	label.text = confirm_text if has_selection() else select_text

func set_button_text(text): select_button.text = text
func get_button_text(): return select_button.text

func _input(event):
	if has_selection() && (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select")):
		finalize_selection()

func cell_input(world_map, grid_cell, event):
	var units = []
	if select_from:
		for unit in world_map.get_units_at_cell(grid_cell):
			if select_from.has(unit):
				units.push_back(unit)
	else:
		units = world_map.get_units_at_cell(grid_cell)

	if !units.empty() && event.is_action_pressed("click_select"):
		set_selection(units)
		if event.doubleclick:
			finalize_selection()

	elif event is InputEventMouseMotion:
		selection_group.set_hovering(units)

func finalize_selection():
	## create a new selection group that has only the selected units
	var selected = selection_group.get_selected()
	var finalize_group = SelectionGroup.new(selection_group.overlay_scene)
	finalize_group.set_selected(selected)

	selection_group.clear()
	context_return(finalize_group)

func _select_button_pressed():
	if has_selection(): finalize_selection()
