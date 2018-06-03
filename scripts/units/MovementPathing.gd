## Generates all possible movement for a unit and stores this information for display and pathing.

extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")
const PriorityQueue = preload("res://scripts/helpers/PriorityQueue.gd")
const MovementModes = preload("res://scripts/game/data/MovementModes.gd")


static func calculate_movement(move_unit):
	assert(move_unit.current_activation)
	
	var unit_model = move_unit.unit_model
	var current_mode = move_unit.current_activation.movement_mode
	
	## calculate pathing for each movement mode and then merge the results
	var possible_moves = {}
	for movement_mode in unit_model.get_movement_modes():
		#once we start using a movement mode, we can only use movement modes that
		#share the same movement type for the rest of the turn
		if current_mode && current_mode.type_id != movement_mode.type_id:
			continue
		
		#don't use reverse movement on units that don't have a facing
		if !move_unit.has_facing() && movement_mode.reversed:
			continue
		
		var movement = new(move_unit, movement_mode)
		for cell_pos in movement.possible_moves:
			var move_info = movement.possible_moves[cell_pos]
			move_info.current_activation = move_unit.current_activation
			
			if !possible_moves.has(cell_pos) || _move_priority_compare(possible_moves[cell_pos], move_info):
				possible_moves[cell_pos] = move_info
	return possible_moves

static func _move_priority_compare(left, right):
	return SortingUtils.lexical_sort(_move_priority_lexical(left), _move_priority_lexical(right))

static func _move_priority_lexical(move_info):
	var current_activation = move_info.current_activation
	var move_mode = move_info.movement_mode

	var moves_remaining = current_activation.movement_points - move_info.move_cost
	var turns_remaining = move_mode.turn_rate - move_info.turn_cost if !move_mode.free_rotate else 0

	return [
		1 if !move_info.hazard else -1, #non-hazardous over hazardous moves
		1 if move_mode.free_rotate else -1, #prefer free rotations
		1 if moves_remaining >= current_activation.EXTENDED_MOVE else -1, #try to avoid extended movement
		turns_remaining, #prefer more turns remaining
		moves_remaining, #prefer more moves remaining
		hash(move_info), #lastly, sort by hash to ensure determinism
	]

const MovementPath = preload("res://scripts/units/MovementPath.gd")

##### Movement Pathing #####

var move_unit #the unit whose movement we are considering
var unit_model
var world_map #reference to the world map the unit is located on
var movement_mode

var _track_turns #flag if we should track facing and turn rate

## a dictionary of the grid positions this unit can reach from the start_loc
## each position is mapped to a dictionary of information (e.g. movement costs, facing at that hex, turning angle used)
var possible_moves = {}

func _init(unit, move_mode):
	move_unit = unit
	unit_model = unit.unit_model
	world_map = unit.world_map
	movement_mode = move_mode

	_track_turns = unit_model.use_facing() && !movement_mode.free_rotate
	
	var start_loc = move_unit.cell_position
	var start_dir = move_unit.facing
	if movement_mode.reversed:
		start_dir = HexUtils.reverse_dir(start_dir) ## reverse the facing
	
	var visited = _search_possible_moves(start_loc, start_dir)
	for cell_pos in visited:
		if cell_pos != start_loc && _can_stop(cell_pos):
			var move_info = visited[cell_pos]
			if movement_mode.reversed:
				move_info.path.reverse_facing() ## un-reverse the facing
			possible_moves[cell_pos] = move_info

## setups a movement state for the beginning of a move action
func _create_move_info(move_path, move_cost, turn_cost):
	return {
		path = move_path,
		movement_mode = movement_mode,
		move_cost = move_cost,
		turn_cost = turn_cost,
		hazard = false,
	}

## lower priority moves are explored first
func _priority(move_state):
	#var on_road = world_map.road_cells.has(move_state.path.last_pos())
	var hazard = 10000 if move_state.hazard else 0
	return 10*move_state.move_cost + move_state.turn_cost + hazard #+ (-100 if on_road else 0)

func _search_possible_moves(start_loc, start_dir):
	var init_path = MovementPath.new()
	init_path.extend(start_loc, start_dir)

	var init_state = _create_move_info(init_path, 0, 0)
	
	var move_queue = PriorityQueue.new()
	move_queue.add(init_state, _priority(init_state))

	var visited = {}
	while !move_queue.empty():
		var next_state = move_queue.pop_min()
		var visit_pos = next_state.path.last_pos()
		if !visited.has(visit_pos):
			visited[visit_pos] = next_state
			_search_neighbors(next_state, visited, move_queue)
	
	return visited

func _search_neighbors(cur_state, visited, move_queue):
	## unpack current state
	var cur_pos = cur_state.path.last_pos()
	
	var neighbors = HexUtils.get_axial_neighbors(cur_pos)
	for move_dir in neighbors:
		var next_pos = neighbors[move_dir]
		var move_cost = cur_state.move_cost
		var turn_cost = cur_state.turn_cost
		
		if visited.has(next_pos):
			continue ## already visited
		
		if not _can_enter(cur_pos, next_pos):
			continue ## can't go this direction, period
		
		## handle turning costs
		if _track_turns:
			var last_facing = cur_state.path.last_facing()
			turn_cost += abs(HexUtils.get_shortest_turn(last_facing, move_dir))
			
			## if we return to our previous facing, refund the turn cost
			## this allows 'straight' zig-zagging, which lessens 
			## the distortion on movement caused by using a hex grid
			var prev_facing = cur_state.path.prev_facing()
			if move_dir == prev_facing:
				turn_cost -= abs(HexUtils.get_shortest_turn(prev_facing, last_facing))
			
			## if we exceed the max turn rate, forfeit the rest of the movement point in order to make the turn
			var move_points = move_unit.current_activation.movement_points - move_cost
			var forfeit = move_points - floor(move_points)
			if forfeit == 0: 
				forfeit += 1

			while turn_cost > movement_mode.turn_rate:
				turn_cost -= movement_mode.turn_rate
				move_cost += forfeit
				forfeit += 1
		
		## handle movement costs
		move_cost += _move_cost(cur_pos, next_pos)
		
		## can we afford this move?
		if move_cost <= move_unit.current_activation.movement_points:
			## visit the next_pos
			var next_path = MovementPath.new(cur_state.path)
			next_path.extend(next_pos, move_dir)

			var next_state = cur_state.duplicate()
			next_state.path = next_path
			next_state.move_cost = move_cost
			next_state.hazard = cur_state.hazard || _is_dangerous(next_pos)

			move_queue.add(next_state, _priority(next_state))


## Figure out if the unit can enter the given cell position
func _can_enter(from_cell, to_cell):
	return world_map.unit_can_pass(move_unit, movement_mode, from_cell, to_cell)

## we may be able to enter but not finish our movement in certain cells
func _can_stop(cell_pos):
	return world_map.unit_can_place(move_unit, cell_pos)

## How much movement must we expend to move from a cell in a given direction?
func _move_cost(from_cell, to_cell):
	return move_unit.get_move_cost(movement_mode, from_cell, to_cell)

## If entering a given cell will trigger a dangerous terrain check
func _is_dangerous(cell_pos):
	return false #TODO
