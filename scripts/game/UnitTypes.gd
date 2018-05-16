extends Node

const MovementModes = preload("res://scripts/game/MovementModes.gd")
const UnitInfo = preload("res://scripts/units/UnitInfo.gd")
const Factions = preload("res://scripts/game/Factions.gd")

const TYPE_VEHICLE = "vehicle"
const TYPE_INFANTRY = "infantry"

var INFO = {
	dummy_vehicle = {
		name = "Dummy Vehicle",
		short_desc = "Armored Personnel Carrier", #one-line description of this unit
		nato_symbol = "wheeled_apc",
		
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
		nato_symbol = "infantry",
		
		unit_type = TYPE_INFANTRY,
		height = 0.5,
		movement = [
			{ mode = MovementModes.INFANTRY, speed = 3.0 },
		],
		
		action_points = 1,
	},
	dummy_gear = {
		name = "Dummy Gear",
		short_desc = "Battle Gear",
		nato_symbol = "gear",
		crew_rank = rank("enlisted", Factions.EN_SPECIALIST),
		
		unit_type = TYPE_VEHICLE,
		
		height = 1.0,
		movement = [
			{ mode = MovementModes.WALKER, speed = 5.0 },
			{ mode = MovementModes.GROUND, speed = 6.0 },
		],
		
		action_points = 1,
	}
}

var _CACHE = {}

func _init():
	for model_id in INFO:
		_CACHE[model_id] = UnitInfo.new(INFO[model_id])

func get_info(model_id):
	return _CACHE[model_id]