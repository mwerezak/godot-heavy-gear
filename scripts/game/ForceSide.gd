extends Node

const ObjectIntel = preload("ObjectIntel.gd")

var game_state

## color overrides, otherwise default_faction is used for colors
var default_faction
var primary_color = null setget , get_primary_color
var secondary_color = null setget , get_secondary_color

var player
var owned_units = {} setget , get_units

var object_intel = {}
var _intel_cache = {}

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
	var prev_owner = unit.owner_side
	if prev_owner != self:
		if prev_owner:
			prev_owner.release_ownership(self)
		unit.set_side(self)
		owned_units[unit] = true

func release_ownership(unit):
	owned_units.erase(unit)

func get_units():
	return owned_units.keys()

func set_intel_level(seen_object, new_level):
	var old_level = get_intel_level(seen_object)
	if new_level != old_level:
		var intel
		var update_data
		if !object_intel.has(seen_object):
			intel = ObjectIntel.create_intel(seen_object, new_level)
			object_intel[seen_object] = intel
			update_data = intel.get_data()
		else:
			intel = object_intel[seen_object]
			update_data = intel.get_update_delta(seen_object, new_level)
			intel.apply_delta(update_data)
			intel.set_intel_level(new_level)
		
		player.update_view({
			object_id = intel.object_id,
			object_type = intel.object_type,
			intel_level = intel.intel_level,
			update_data = update_data,
		})

func get_intel_level(seen_object):
	if !object_intel.has(seen_object):
		return
	return object_intel[seen_object].intel_level
