## Container for all state related to a unit's activation
## e.g. action points/moves remaining etc.

extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")

## units with less than this many movement points left are consided
## to be performing extended movement, which can cause penalties
const EXTENDED_MOVE = 1

var active_unit

var action_points
var move_actions
var movement_mode

## for partial move actions
var partial_moves = 0
var partial_turns = 0

## how far the unit has moved this activation
## a proxy for how fast the unit is moving
## determines modifiers to hit and defend
var distance_moved = 0

func _init(unit):
	var unit_info = unit.unit_info
	active_unit = unit
	action_points = unit_info.max_action_points()
	move_actions = unit_info.max_move_actions()

func is_extended_movement():
	return move_actions < EXTENDED_MOVE

## any moves left?
func can_move():
	return move_actions + floor(partial_moves/WorldMap.UNITGRID_SIZE) > 0

## any turns left?
func can_rotate():
	return active_unit.has_facing() && (move_actions + partial_turns > 0 || (movement_mode && movement_mode.free_rotate))

## active unit actions

func move(move_info):
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