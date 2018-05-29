extends Node

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
	
	"""
	var select_unit = current_scene.gui.select_unit
	select_unit.setup()
	var selection = yield(select_unit, "unit_selected")
	assert(selection.size() == 1)
	print(selection.selected.front())
	"""
	
	"""
	var select_unit_context = context_panel.activate("activate_unit")
	var selected_unit = yield(select_unit_context, "unit_selected")
	
	EventDispatch.fire_event(EventDispatch.UnitActivated, [selected_unit])
	var unit_actions_context = context_panel.activate("unit_actions", { unit = selected_unit })
	yield(unit_actions_context, "done")
	
	EventDispatch.fire_event(EventDispatch.PlayerPassed, [self])
	"""