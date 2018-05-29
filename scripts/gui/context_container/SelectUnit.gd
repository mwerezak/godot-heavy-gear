## Returns the selected units as an array.

extends "ContextBase.gd"

const UnitSelectorSingle = preload("res://scripts/gui/UnitSelectorSingle.gd")

export(Color) var hover_color = Color(0.7, 0.7, 0.7, 0.5)
export(Color) var selected_color = Color(0.35, 1.0, 0.35, 1.0)

var unit_selector = UnitSelectorSingle.new(
	OverlayFactory.new(hover_color),
	OverlayFactory.new(selected_color)
)

var selection = null setget set_selection

var select_text setget set_select_text
var confirm_text setget set_confirm_text
var button_text setget set_button_text, get_button_text

onready var label = $MarginContainer/HBoxContainer/Label
onready var select_button = $MarginContainer/HBoxContainer/SelectButton

func _init():
	load_properties = {
		select_text = "Select a unit.",
		confirm_text = "Select a unit (or double-click to confirm).",
		button_text = "Select",
	}

func _ready():
	hide()

func _become_active():
	._become_active()
	select_button.grab_focus()

func deactivated():
	.deactivated()
	set_selection(null)

func set_selection(new_selection):
	selection = new_selection
	select_button.disabled = !has_selection()
	_update_label()

func has_selection():
	return selection && selection.size() > 0

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
	if selection && (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select")):
		finalize_selection()

func cell_input(world_map, grid_cell, event):
	var units = world_map.get_units_at_cell(grid_cell)

	if !units.empty() && event.is_action_pressed("click_select"):
		if selection: selection.cleanup()

		var new_selection = unit_selector.create_selection(units, selection)

		var highlight = []
		for unit in units: if !new_selection.selected.has(unit): highlight.push_back(unit)
		unit_selector.highlight_objects(highlight)

		set_selection(new_selection)
		if event.doubleclick:
			finalize_selection()

	elif event is InputEventMouseMotion:
		var cur_selected = selection.selected if selection else []
		var highlight = []
		for unit in units: if !cur_selected.has(unit): highlight.push_back(unit)
		unit_selector.highlight_objects(highlight)

func finalize_selection():
	context_return(selection.selected)

func _select_button_pressed():
	if has_selection(): finalize_selection()

## TODO split to another file
const Constants = preload("res://scripts/Constants.gd")
class OverlayFactory:
	#const _overlay_texture = preload("res://icons/selection_marker_16.png")
	const _overlay_scene = preload("res://scripts/gui/SelectionMarker.tscn")
	var _modulate_color

	func _init(modulate_color):
		_modulate_color = modulate_color

	func create_overlay_node(unit):
		var overlay = _overlay_scene.instance()
		overlay.modulate = _modulate_color

		overlay.text = unit.crew_info.last_name

		overlay.z_as_relative = false
		overlay.z_index = Constants.HUD_ZLAYER
		return overlay

