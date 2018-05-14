extends Node

const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")

const TYPE_VEHICLE = "vehicle"
const TYPE_INFANTRY = "infantry"

const INFO = {
	dummy_vehicle = {
		name = "Dummy Vehicle",
		nato_symbol = "wheeled_apc",
		unit_type = TYPE_VEHICLE,
		
		height = 1.0,
		movement = {
			MovementTypes.TYPE_GROUND: 7.0,
		},
	},
	dummy_infantry = {
		name = "Dummy Infantry",
		nato_symbol = "infantry",
		unit_type = TYPE_INFANTRY,
		
		height = 0.5,
		movement = {
			MovementTypes.TYPE_INFANTRY: 3.0,
		},
	},
	dummy_gear = {
		name = "Dummy Gear",
		nato_symbol = "gear",
		unit_type = TYPE_VEHICLE,
		
		height = 1.0,
		movement = {
			MovementTypes.TYPE_WALKER: 5.0,
		},
	}
}

class UnitInfo:
	var _info
	
	func _init(info):
		_info = info
	
	func get_name(): return _info.name
	func get_symbol(): return _info.nato_symbol
	func use_facing(): return !is_infantry()
	
	func is_vehicle(): return _info.unit_type == TYPE_VEHICLE
	func is_infantry(): return _info.unit_type == TYPE_INFANTRY
	
	func get_movement_modes(): 
		return _info.movement.keys()
	func get_move_speed(move_mode): 
		return _info.movement[move_mode]
	func get_turn_rate(move_mode):
		return MovementTypes.INFO[move_mode].turn_rate if use_facing() else null
	
	## returns a multiplier that is applied to the distance moved to get the cost.
	func get_move_cost_on_terrain(move_mode, terrain_info):
		if !terrain_info.difficult.has(move_mode):
			return 1.0
		var base_speed = get_move_speed(move_mode)
		var speed_limit = min(base_speed, terrain_info.difficult[move_mode]) #difficult terrain cannot make us move /faster/
		return base_speed/speed_limit

var _CACHE = {}

func _init():
	for model_id in INFO:
		_CACHE[model_id] = UnitInfo.new(INFO[model_id])

func get_info(model_id):
	return _CACHE[model_id]