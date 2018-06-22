extends Node

const Factions = preload("Factions.gd")
const MovementModes = preload("MovementModes.gd")
const UnitModel = preload("UnitModel.gd")

## NATO symbol textures
const NATO_SYMBOLS = {
	unknown = preload("res://icons/units/unknown.png"),
	infantry = preload("res://icons/units/infantry.png"),
	wheeled_apc = preload("res://icons/units/wheeled_apc.png"),
	tank = preload("res://icons/units/tank.png"),
	gear = preload("res://icons/units/gear.png"),
}

## Unit types
enum { TYPE_VEHICLE, TYPE_INFANTRY }

## Unit types that can be inherited, but are not used to create a UnitInfo
var BASE_TYPES = {
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

## Each entry generates a UnitInfo object during initialization
var INFO = {
	dummy_vehicle = {
		name = "Dummy Vehicle",
		short_desc = "Armored Personnel Carrier", #one-line description of this unit
		nato_symbol = "wheeled_apc",
		default_crew = {
			rank = Factions.RANK_SPECIALIST,
			skills = {}, #TODO
		},
		
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
		inherits = "default_infantry",
		default_crew = {
			rank = Factions.RANK_SQUAD_LEAD,
			skills = {}, #TODO
		},
	},
	dummy_gear = {
		name = "Dummy Gear",
		short_desc = "Battle Gear",
		inherits = "default_gear",
		default_crew = {
			rank = Factions.RANK_SPECIALIST,
			skills = {}, #TODO
		},
	}
}

var _UNITMODEL_CACHE = {}

func _apply_override(parent, child):
	var result = parent.duplicate()
	for key in child:
		result[key] = child[key]
	return result

func _resolve_dependencies(child_id, resolve_cache):
	if resolve_cache.has(child_id):
		return resolve_cache[child_id]
	
	var child = INFO[child_id] if INFO.has(child_id) else BASE_TYPES[child_id]
	if child.has("inherits"):
		var parent_id = child.inherits
		if !resolve_cache.has(parent_id):
			_resolve_dependencies(parent_id, resolve_cache)
		
		var parent = resolve_cache[parent_id]
		child = _apply_override(parent, child)
	
	resolve_cache[child_id] = child

func _init():
	var all_models = INFO.keys()
	
	## include model IDs in data structure
	for model_id in all_models:
		INFO[model_id].model_id = model_id
	
	## resolve all inherit references
	var resolve_cache = {}
	for model_id in all_models:
		_resolve_dependencies(model_id, resolve_cache)
	
	for model_id in all_models:
		var resolved_info = resolve_cache[model_id]
		_UNITMODEL_CACHE[model_id] = UnitModel.new(resolved_info)

func get_model(model_id):
	return _UNITMODEL_CACHE[model_id]

