extends Node

export(String) var display_name
export(String) var faction_id setget set_faction_id

export(Color) var primary_color
export(Color) var secondary_color

var default_faction setget set_faction
var owned_units = {} setget , get_units

var game_state

func _ready():
	game_state = get_parent()

func set_faction_id(new_faction_id):
	if new_faction_id:
		set_faction(GameData.get_faction(new_faction_id))

func set_faction(new_faction):
	faction_id = new_faction.faction_id
	default_faction = new_faction
	
	if !primary_color:
		primary_color = default_faction.primary_color
	if !secondary_color:
		secondary_color = default_faction.secondary_color

func take_ownership(unit):
	owned_units[unit] = true

func release_ownership(unit):
	owned_units.erase(unit)

func get_units():
	return owned_units.keys()

## Turn Control

signal pass_turn

func activation_turn(current_turn, available_units):
	emit_signal("pass_turn") #override in subtype
