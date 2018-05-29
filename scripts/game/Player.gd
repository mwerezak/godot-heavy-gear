extends Node

const UnitActivation = preload("res://scripts/units/UnitActivation.gd")

export(String) var display_name
export(String) var faction_id

export(Color) var primary_color
export(Color) var secondary_color

var default_faction setget set_faction

func _ready():
	 set_faction(GameData.get_faction(faction_id))

func set_faction(new_faction):
	faction_id = new_faction.faction_id
	default_faction = new_faction
	
	if !primary_color:
		primary_color = default_faction.primary_color
	if !secondary_color:
		secondary_color = default_faction.secondary_color

func activate_player():
	var current_scene = get_tree().get_current_scene()
	var context_panel = current_scene.context_panel
	
	var selected_units = yield(context_panel.activate("SelectUnit", {
		select_text = "Select a unit to activate.",
		confirm_text = "Select a unit to activate (or double-click to confirm).",
		button_text = "Activate",
	}), "context_return")
	
	assert(selected_units.size() == 1)
	var selected_unit = selected_units.front()
	
	selected_unit.current_activation = UnitActivation.new(selected_unit)
	yield(context_panel.activate("UnitActions", { active_unit = selected_unit }), "context_return")
	
	EventDispatch.fire_event(EventDispatch.PlayerPassed, [self])
	
	"""
	var select_unit = current_scene.gui.select_unit
	select_unit.setup()

	"""
	
	"""
	var select_unit_context = context_panel.activate("activate_unit")
	var selected_unit = yield(select_unit_context, "unit_selected")
	
	EventDispatch.fire_event(EventDispatch.UnitActivated, [selected_unit])
	var unit_actions_context = context_panel.activate("unit_actions", { unit = selected_unit })
	yield(unit_actions_context, "done")
	
	EventDispatch.fire_event(EventDispatch.PlayerPassed, [self])
	"""