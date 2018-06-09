extends Node

export(String) var display_name
export(String) var faction_id

export(Color) var primary_color
export(Color) var secondary_color

onready var gui = $PlayerGUI

signal pass_turn

var default_faction setget set_faction
var owned_units = []

var game_state

func _ready():
	game_state = get_parent()
	set_faction(GameData.get_faction(faction_id))
	gui.hide()

func setup(world_map):
	gui.setup(world_map)

func set_faction(new_faction):
	default_faction = new_faction
	faction_id = new_faction.faction_id
	
	if !primary_color:
		primary_color = default_faction.primary_color
	if !secondary_color:
		secondary_color = default_faction.secondary_color

func take_ownership(unit):
	owned_units.push_back(unit)

func release_ownership(unit):
	owned_units.erase(unit)

func activation_turn(current_turn, available_units):
	get_tree().get_current_scene().set_active_player(self)

	#gui.camera.focus_objects(available_units)

	var select_unit = gui.context_panel.activate("SelectUnit", {
		select_from = available_units,
		select_text = "Select a unit to activate.",
		confirm_text = "Select a unit to activate (or double-click to confirm).",
		button_text = "Activate",
	})
	var selection_group = yield(select_unit, "context_return")
	var selected = selection_group.get_selected()
	
	assert(selected.size() == 1)
	assert(available_units.has(selected.front()))
	
	var unit = selected.front()
	var current_activation = current_turn.activate_unit(unit)
	
	yield(gui.context_panel.activate("UnitActions", { current_activation = current_activation }), "context_return")
	
	selection_group.clear()

	emit_signal("pass_turn")
