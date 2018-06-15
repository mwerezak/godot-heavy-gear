extends Node

var game_state

var player
var default_faction

var owned_units = {} setget , get_units

func _init(game_state, player):
	self.game_state = game_state
	self.player = player
	self.default_faction = GameData.get_faction(player.faction_id)

func get_player_name(): 
	return player.display_name

func get_primary_color():
	if player.primary_color:
		return player.primary_color
	return default_faction.primary_color

func get_secondary_color():
	if player.secondary_color:
		return player.secondary_color
	return default_faction.secondary_color

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
