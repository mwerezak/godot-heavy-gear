extends Node

const MovementModes = preload("res://scripts/Game/MovementModes.gd")

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

class UnitInfo:
	var _info
	var _movement_modes = []
	
	func _init(info):
		_info = info
		
		## setup movement mode data
		for item in info.movement:
			var mode = item.mode
			var mode_info = MovementModes.get_info(mode)
			
			var mode_data = {
				mode_id = mode,
				name = mode_info.name,
				speed = item.speed,
				turn_rate = mode_info.turn_rate,
				free_rotate = (mode_info.turn_rate == null),
				reversed = false,
			}
			_movement_modes.push_back(mode_data)
			
			if item.has("reverse"):
				var reverse_data = mode_data.duplicate()
				reverse_data.name += " (Reverse)"
				reverse_data.reversed = true
				reverse_data.speed = item.reverse
				_movement_modes.push_back(reverse_data)
	
	func get_name(): return _info.name
	func get_symbol(): return _info.nato_symbol
	func use_facing(): return !is_infantry()
	
	func is_vehicle(): return _info.unit_type == TYPE_VEHICLE
	func is_infantry(): return _info.unit_type == TYPE_INFANTRY
	
	func get_movement_modes(): 
		return _movement_modes
	
	## returns a multiplier that is applied to the distance moved to get the cost.
	func get_move_cost_on_terrain(move_mode, terrain_info):
		var mode_id = move_mode.mode_id
		if !terrain_info.difficult.has(mode_id):
			return 1.0
		var base_speed = move_mode.speed
		var speed_limit = min(base_speed, terrain_info.difficult[mode_id]) #difficult terrain cannot make us move /faster/
		return base_speed/speed_limit

var _CACHE = {}

func _init():
	for model_id in INFO:
		_CACHE[model_id] = UnitInfo.new(INFO[model_id])

func get_info(model_id):
	return _CACHE[model_id]