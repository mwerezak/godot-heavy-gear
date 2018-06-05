## Calculates movement costs along a given path for a unit.

extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var move_unit
var move_mode

var positions ## array of cells visited along the path
var facing   ## array of directions at each positions

var moves_used ## movement points used
var turns_used ## total direction steps turned

## TODO hazards

func _init(move_unit, move_mode):
	self.move_unit = move_unit
	self.move_mode = move_mode

## starts movement with a given positions and facing
func start_movement(start_pos, start_facing):
	positions = [ start_pos ]
	facing = [ start_facing ]
	moves_used = 0.0
	turns_used = 0

## starts movement continuing from a given MovementPath
func continue_movement(prev_path):
	positions = [ prev_path.last_pos() ]
	facing = [ prev_path.last_facing() ]
	moves_used = prev_path.moves_used
	turns_used = prev_path.turns_used

func duplicate():
	var copy = get_script().new(move_unit, move_mode)
	copy.positions = positions.duplicate()
	copy.facing = facing.duplicate()
	copy.moves_used = moves_used
	copy.turns_used = turns_used
	return copy

func size():
	return positions.size()

func last_pos():
	return positions.back()

func last_facing():
	return facing.back()

func prev_facing():
	if !facing.empty():
		return facing[max(facing.size()-2, 0)]
	return null

## return cost in movement points to reach next positions.
## next_facing is the direction turned BEFORE moving
## returns a new MovementPath, without altering the current one
func extended(next_pos, next_facing):
	var extended = duplicate()
	extended._extend(next_pos, next_facing)
	return extended

func _extend(next_pos, next_facing):
	var prev_moves = moves_used
	
	if move_mode.reversed:
		next_facing = HexUtils.reverse_dir(next_facing) #face away from the desired direction when reversing

	var costs = get_move_costs(next_pos, next_facing)
	moves_used += costs.move_cost
	turns_used += costs.turn_cost

	## when we begin spending our next movement point, reset turns_used
	if !_free_rotate() && int(moves_used) > int(prev_moves):
		turns_used = max(turns_used - move_mode.turn_rate, 0)

	positions.push_back(next_pos)
	facing.push_back(next_facing)

func _free_rotate():
	return !move_unit.unit_model.use_facing() || move_mode.free_rotate

## get the map this path is on
func get_world_map():
	return move_unit.world_map

func get_move_costs(next_pos, next_facing):
	## costs due to movement
	var move_cost = move_unit.get_move_cost(move_mode, last_pos(), next_pos)
	var turn_cost = 0

	## costs due to turning
	if !_free_rotate():
		turn_cost = _turn_cost(next_facing)

		var total_moves = moves_used + move_cost
		var total_turns = turns_used + turn_cost

		## allowed a number of direction steps per move point determined by turn rate
		if total_turns > move_mode.turn_rate:
			## if we exceed the max turn rate, forfeit any fractional move points
			var forfeit = _next_int(total_moves) - total_moves
			move_cost += forfeit

	return {
		move_cost = move_cost,
		turn_cost = turn_cost,
	}

## return cost in direction steps - can be negative
func _turn_cost(new_facing):
	var cost = abs(HexUtils.get_shortest_turn(last_facing(), new_facing))
	
	## if we return to our previous facing, refund the turn cost
	## this allows 'straight' zig-zagging, which lessens 
	## the distortion on movement caused by using a hex grid
	if new_facing == prev_facing():
		cost -= abs(HexUtils.get_shortest_turn(prev_facing(), last_facing()))

	return cost

## gets the next largest integer
static func _next_int(value):
	if int(value) == value:
		return value + 1
	return ceil(value)