extends Node

const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")

## default base sizes
const BASE_SIZE_GEAR = 1.0
const BASE_SIZE_GEAR_LARGE = 1.5
const BASE_SIZE_INFANTRY = 1.5
const BASE_SIZE_VEHICLE = 1.5
const BASE_SIZE_VEHICLE_LARGE = 3.0
const BASE_SIZE_STRIDER = 1.5

const TYPE_VEHICLE = "vehicle"
const TYPE_INFANTRY = "infantry"

const INFO = {
	dummy = {
		name = "Dummy Unit",
		unit_type = TYPE_VEHICLE,
		
		base_size = 1.0,
		height = 0.5,
		movement = {
			MovementTypes.TYPE_GROUND: 5.0,
		},
	}
}

class UnitInfo:
	var _info
	
	func _init(info):
		_info = info
	
	func get_name(): return _info.name
	func get_base_size(): return _info.base_size
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

static func get_info(model_id):
	return UnitInfo.new(INFO[model_id])