extends Node

const MovementModes = preload("res://scripts/Game/MovementModes.gd")
const UnitInfo = preload("res://scripts/Units/UnitInfo.gd")

const TYPE_VEHICLE = "vehicle"
const TYPE_INFANTRY = "infantry"

const INFO = {
	dummy_vehicle = {
		name = "Dummy Vehicle",
		nato_symbol = "wheeled_apc",
		unit_type = TYPE_VEHICLE,
		
		height = 1.0,
		movement = [
			{ mode = MovementModes.GROUND, speed = 7.0, reverse = 3.0 },
		],
	},
	dummy_infantry = {
		name = "Dummy Infantry",
		nato_symbol = "infantry",
		unit_type = TYPE_INFANTRY,
		
		height = 0.5,
		movement = [
			{ mode = MovementModes.INFANTRY, speed = 3.0 },
		],
	},
	dummy_gear = {
		name = "Dummy Gear",
		nato_symbol = "gear",
		unit_type = TYPE_VEHICLE,
		
		height = 1.0,
		movement = [
			## order determines movement priority
			{ mode = MovementModes.WALKER, speed = 5.0 },
			{ mode = MovementModes.GROUND, speed = 6.0 },
		],
	}
}

var _CACHE = {}

func _init():
	for model_id in INFO:
		_CACHE[model_id] = UnitInfo.new(INFO[model_id])

func get_info(model_id):
	return _CACHE[model_id]