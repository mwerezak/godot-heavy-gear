extends Node

export(String) var display_name
export(String) var faction_id

export(Color) var primary_color
export(Color) var secondary_color

var default_faction setget set_faction

var game_state

func _ready():
	game_state = get_parent()
	set_faction(GameData.get_faction(faction_id))

func set_faction(new_faction):
	default_faction = new_faction
	faction_id = new_faction.faction_id
	
	if !primary_color:
		primary_color = default_faction.primary_color
	if !secondary_color:
		secondary_color = default_faction.secondary_color

func activation_turn():
	var _state = null
	var current_scene = get_tree().get_current_scene()
	var select_units = current_scene.ui_context.SelectUnit
	var unit_actions = current_scene.ui_context.UnitActions

	_state = select_units.context_call({
		selectable_units = game_state.world_map.all_units(), #stub
		select_text = "Select a unit to activate.",
		confirm_text = "Select a unit to activate (or double-click to confirm).",
		button_text = "Activate",
	})
	var selection_group = yield(_state, "completed")
	var selected = selection_group.get_selected()
	
	assert(selected.size() == 1)
	var unit = selected.front()
	activate_unit(unit)
	
	_state = unit_actions.context_call({ active_unit = unit })
	yield(_state, "completed")
	
	selection_group.clear()

	game_state.pass_player(self)

func activate_unit(unit):
	unit.activate()