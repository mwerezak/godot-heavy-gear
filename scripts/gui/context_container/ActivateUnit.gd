extends "ContextBase.gd"

const UnitSelectorSingle = preload("res://scripts/gui/UnitSelectorSingle.gd")
const Constants = preload("res://scripts/Constants.gd")

## TODO split to another file
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

export(Color) var hover_color = Color(0.7, 0.7, 0.7, 0.5)
export(Color) var selected_color = Color(0.35, 1.0, 0.35, 1.0)

var unit_selector = UnitSelectorSingle.new(
	OverlayFactory.new(hover_color),
	OverlayFactory.new(selected_color)
)

var selection = null setget set_selection

onready var activate_button = $MarginContainer/HBoxContainer/Activate
onready var label = $MarginContainer/HBoxContainer/Label

signal unit_selected(unit, arg)

func _ready():
	set_selection(null)

func deactivated():
	.deactivated()
	set_selection(null)

func _become_active():
	._become_active()
	if selection:
		selection.cleanup()
		set_selection(null)
	activate_button.grab_focus()

func _input(event):
	if selection && (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select")):
		activate_selected()

func cell_input(world_map, cell_pos, event):
	var units = world_map.get_units_at_cell(cell_pos)

	if !units.empty() && event.is_action_pressed("click_select"):
		if selection: selection.cleanup()

		var new_selection = unit_selector.create_selection(units, selection)

		var highlight = []
		for unit in units: if !new_selection.selected.has(unit): highlight.push_back(unit)
		unit_selector.highlight_objects(highlight)

		var confirm_selection = new_selection.equals(selection)
		set_selection(new_selection)
		if confirm_selection: activate_selected()

	elif event is InputEventMouseMotion:
		var cur_selected = selection.selected if selection else []
		var highlight = []
		for unit in units: if !cur_selected.has(unit): highlight.push_back(unit)
		unit_selector.highlight_objects(highlight)

func set_selection(s):
	selection = s
	activate_button.disabled = (s == null)
	if s && unit_selector.get_highlighted_objects().size() == 0:
		label.text = "Select a unit to activate (or click again to confirm)."
	else:
		label.text = "Select a unit to activate."

func activate_selected():
	var selected_unit = selection.selected.front()
	emit_signal("unit_selected", selected_unit)
	context_manager.deactivate()

func _activate_button_pressed():
	if selection: activate_selected()

