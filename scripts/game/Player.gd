extends Node

export(String) var display_name
export(String) var faction_id

export(Color) var primary_color
export(Color) var secondary_color

signal pass_turn

var default_faction setget set_faction
var owned_units = []

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
	owned_units.push_back(unit)

func release_ownership(unit):
	owned_units.erase(unit)

#override in subtype
func activation_turn(current_turn, available_units):
	emit_signal("pass_turn")
