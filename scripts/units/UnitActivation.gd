## Container for all state related to a unit's activation
## e.g. action points/moves remaining etc.

extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")

## units with less than this amount of movement points left are consided
## to be performing extended movement, which can cause penalties
const EXTENDED_MOVE = 1.0

var active_unit

var actions_used = 0

var move_paths = [] ## list the moves made during this activation

func _init(unit):
	active_unit = unit

func last_movement_path():
	return move_paths.back()

func current_move_mode():
	var last_path = last_movement_path()
	if last_path: 
		return last_path.move_mode
	return null

## once we start using a movement mode, we can only use movement modes that share the same movement type for the rest of the activation
func available_movement_modes():
	var movement_modes = active_unit.unit_model.get_movement_modes()

	var current_mode = current_move_mode()
	if !current_mode:
		return movement_modes

	var rval = []
	for move_mode in movement_modes:
		if move_mode.type_id == current_mode.type_id:
			rval.push_back(move_mode)
	return rval


"""
## any moves left?
func can_move():
	assert(false) ##TODO
	return move_actions + floor(partial_moves/WorldMap.UNITGRID_SIZE) > 0

## any turns left?
func can_rotate():
	assert(false) ##TODO
	return active_unit.has_facing() && (move_actions + partial_turns > 0 || (movement_mode && movement_mode.free_rotate))

## active unit actions

func move(move_info):
	## pretty permissive for now
	## unlike rotate(), we just use the results provided in move_info instead of simulating the move step by step

	active_unit.cell_position = move_info.path.back()
	if move_info.facing != null:
		active_unit.facing = move_info.facing
	
	move_actions -= move_info.move_count
	partial_moves = move_info.moves_remaining
	partial_turns = move_info.turns_remaining if move_info.turns_remaining else 0
	
	movement_mode = move_info.movement_mode
	distance_moved += active_unit.world_map.path_distance(move_info.path)

func rotate(rotate_mode, dir):
	if rotate_mode.free_rotate:
		active_unit.facing = dir
	else:
		var new_facing = active_unit.facing
		var rotate_dir = sign(HexUtils.get_shortest_turn(active_unit.facing, dir))
		while new_facing != dir:
			if partial_turns > 0:
				partial_turns -= 1
			elif move_actions > 0:
				move_actions -= 1
				partial_turns = rotate_mode.turn_rate - 1
				partial_moves += rotate_mode.speed #note that partial moves carry over, partial turns do not
			else:
				#out of turns!
				break
			
			new_facing = HexUtils.rotate_step(new_facing, rotate_dir)
		active_unit.facing = new_facing

func get_rotation_cost(rotate_mode, dir):
	var total_turn_cost = abs(HexUtils.get_shortest_turn(active_unit.facing, dir))
	var move_actions = ceil(1.0*(total_turn_cost - partial_turns)/rotate_mode.turn_rate)
	return {
		total_turn_cost = total_turn_cost,
		move_actions = max(move_actions, 0),
	}
"""