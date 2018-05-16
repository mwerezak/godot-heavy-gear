extends Node

const MovementModes = preload("res://scripts/game/MovementModes.gd")
const UnitInfo = preload("res://scripts/units/UnitInfo.gd")
const Factions = preload("res://scripts/game/Factions.gd")

const TYPE_VEHICLE = "vehicle"
const TYPE_INFANTRY = "infantry"

const DEFAULTS = {
	default_gear = {
		nato_symbol = "gear",
		unit_type = TYPE_VEHICLE,
		height = 1.0,
		movement = [
			{ mode = MovementModes.WALKER, speed = 5.0 },
			{ mode = MovementModes.GROUND, speed = 6.0 },
		],
		action_points = 1,
	},
	default_infantry = {
		nato_symbol = "infantry",
		unit_type = TYPE_INFANTRY,
		height = 0.5,
		movement = [
			{ mode = MovementModes.INFANTRY, speed = 3.0 },
		],
		action_points = 1,
	},
}

const INFO = {
	dummy_vehicle = {
		name = "Dummy Vehicle",
		short_desc = "Armored Personnel Carrier", #one-line description of this unit
		nato_symbol = "wheeled_apc",
		crew_rank = Factions.RANK_SPECIALIST,
		
		unit_type = TYPE_VEHICLE,
		height = 1.0,
		## a array of movement specs. These are used to create the unit's movement modes (see MovementModes.gd)
		movement = [
			{ mode = MovementModes.GROUND, speed = 7.0, reverse = 3.0 },
		],
		
		action_points = 1,
	},
	dummy_infantry = {
		name = "Dummy Infantry",
		short_desc = "Infantry Squad",
		crew_rank = Factions.RANK_SQUAD_LEAD,
		inherits = "default_infantry",
	},
	dummy_gear = {
		name = "Dummy Gear",
		short_desc = "Battle Gear",
		crew_rank = Factions.RANK_SPECIALIST,
		inherits = "default_gear",
	}
}

var _CACHE = {}

func _apply_override(parent, child):
	var result = parent.duplicate()
	for key in child:
		result[key] = child[key]
	return result

func _resolve_dependencies(child_id, resolve_cache):
	if resolve_cache.has(child_id):
		return resolve_cache[child_id]
	
	var child = INFO[child_id] if INFO.has(child_id) else DEFAULTS[child_id]
	if child.has("inherits"):
		var parent_id = child.inherits
		if !resolve_cache.has(parent_id):
			_resolve_dependencies(parent_id, resolve_cache)
		
		var parent = resolve_cache[parent_id]
		child = _apply_override(parent, child)
	
	resolve_cache[child_id] = child

func _init():
	var all_models = INFO.keys()
	
	## resolve all inherit references
	var resolve_cache = {}
	for model_id in all_models:
		_resolve_dependencies(model_id, resolve_cache)
	
	for model_id in all_models:
		var resolved_info = resolve_cache[model_id]
		_CACHE[model_id] = UnitInfo.new(resolved_info)

func get_info(model_id):
	return _CACHE[model_id]

