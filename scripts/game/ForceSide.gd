extends Node

var game_state

var player
var owned_units = {} setget , get_units

## color overrides, otherwise default_faction is used for colors
var default_faction
var primary_color = null setget , get_primary_color
var secondary_color = null setget , get_secondary_color

func _init(game_state, player, seat_info):
	self.game_state = game_state
	self.player = player

	self.default_faction = GameData.get_faction(seat_info.faction_id)
	primary_color = seat_info.primary_color if seat_info.has("primary_color") else null
	secondary_color = seat_info.secondary_color if seat_info.has("secondary_color") else null

func get_player_name(): 
	return player.display_name

func get_primary_color():
	return primary_color if primary_color else default_faction.primary_color

func get_secondary_color():
	return secondary_color if secondary_color else default_faction.secondary_color

func take_ownership(unit):
	owned_units[unit] = true

func release_ownership(unit):
	owned_units.erase(unit)

func get_units():
	return owned_units.keys()

