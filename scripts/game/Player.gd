extends Node

export(String) var display_name
export(String) var faction_id

export(Color) var primary_color
export(Color) var secondary_color

var default_faction setget set_faction
var units = []

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

func take_ownership(unit):
	units.push_back(unit)

func release_ownership(unit):
	units.erase(unit)

func activation_turn(current_turn):
	var current_scene = get_tree().get_current_scene()
	var context_panel = current_scene.context_panel

	var select_unit = context_panel.activate("SelectUnit",
	{
		selectable_units = game_state.world_map.all_units(), #stub
		select_text = "Select a unit to activate.",
		confirm_text = "Select a unit to activate (or double-click to confirm).",
		button_text = "Activate",
	})
	var selection_group = yield(select_unit, "context_return")
	var selected = selection_group.get_selected()
	
	assert(selected.size() == 1)
	var unit = selected.front()
	var current_activation = current_turn.activate_unit(unit)
	
	yield(context_panel.activate("UnitActions", { current_activation = current_activation }), "context_return")
	
	selection_group.clear()

	game_state.pass_player(self)

