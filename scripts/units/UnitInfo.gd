extends Reference

const UnitModels = preload("res://scripts/game/UnitModels.gd")
const MovementModes = preload("res://scripts/game/MovementModes.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")

const MAX_MOVE_ACTIONS = 2

var desc

var _info
var _movement_modes = []
var _default_rotation #the movement mode used by default for rotations

func _init(info):
	_info = info
	
	desc = { 
		name = info.name,
		short = info.short_desc,
		symbol = info.nato_symbol,
	}
	
	## setup movement mode data
	for move_spec in info.movement:
		var move_mode = MovementModes.create(move_spec, move_spec.mode)
		_movement_modes.push_back(move_mode)
		
		if move_spec.has("reverse"):
			var reversed_mode = MovementModes.create_reversed(move_spec, move_spec.mode)
			_movement_modes.push_back(reversed_mode)
	
	_default_rotation = SortingUtils.get_max_item(_movement_modes, self, "_compare_default_rotation")

func _compare_default_rotation(left, right):
	return SortingUtils.lexical_sort(
		MovementModes.default_rotation_lexical(left), 
		MovementModes.default_rotation_lexical(right)
	)

func get_model_id(): return _info.model_id

func get_default_crew(): return _info.default_crew

func use_facing(): return !is_infantry()

func is_vehicle(): return _info.unit_type == UnitModels.TYPE_VEHICLE
func is_infantry(): return _info.unit_type == UnitModels.TYPE_INFANTRY

func max_action_points(): return _info.action_points
func max_move_actions(): return MAX_MOVE_ACTIONS

func get_movement_modes(): 
	return _movement_modes
func get_default_rotation():
	return _default_rotation

## returns a multiplier that is applied to the distance moved to get the cost.
func get_move_cost_on_terrain(move_mode, terrain_info):
	var type_id = move_mode.type_id
	var base_speed = move_mode.speed
	
	## roads bypass difficult terrain
	if terrain_info.has_road:
		return base_speed/(base_speed + move_mode.road_bonus)
	
	if !terrain_info.difficult.has(type_id):
		return 1.0
	
	var speed_limit = min(base_speed, terrain_info.difficult[type_id]) #difficult terrain cannot make us move /faster/
	return base_speed/speed_limit

