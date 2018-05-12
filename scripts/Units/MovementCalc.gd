## Generates all possible movement for a unit and stores this information for display and pathing.

extends Reference

const HexUtils = preload("res://scripts/HexUtils.gd")
const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")
#const PriorityQueue = preload("res://scripts/Game/DataStructures/PriorityQueue.gd")

var unit #the unit whose movement we are considering
var world_map #reference to the world map the unit is located on
var movement_type #movement type to use, since units may have more than one
var _track_turns

## a dictionary of the grid positions this unit can reach from the start_loc
## each position is mapped to a dictionary of information (e.g. movement costs, facing at that hex, turning angle used)
var possible_moves = {}

## cached data
var _grid_spacing
var _movement_rate #amount of movement per move action
var _turning_rate  #amount of turning per move action

func _init(world_map, unit, movement_type, max_moves=2, start_loc=null, start_dir=null):
	self.world_map = world_map
	self.unit = unit
	self.movement_type = movement_type
	
	start_loc = start_loc if start_loc else unit.cell_position
	start_dir = start_dir if start_dir else unit.facing
	
	_grid_spacing = HexUtils.pixels2units(world_map.UNITGRID_WIDTH)
	
	var unit_info = unit.unit_info
	var move_type_info = MovementTypes.INFO[movement_type]
	
	_track_turns = (move_type_info.turn_rate != null && unit.has_facing()) #TODO get this from the unit somehow
	_movement_rate = unit_info.movement[movement_type]
	_turning_rate = move_type_info.turn_rate
	
	var visited = _search_possible_moves(start_loc, start_dir, max_moves)
	for cell_pos in visited:
		if cell_pos != start_loc && _can_stop(cell_pos):
			possible_moves[cell_pos] = visited[cell_pos]


## setups a movement state for the beginning of a move action
func _init_move_state(move_count, facing, move_path):
	return {
		move_count = move_count,
		facing = facing,
		move_remaining = _movement_rate,
		turn_remaining = _turning_rate,
		hazard = false,
		path = move_path,
	}

func _search_possible_moves(start_loc, start_dir, max_moves):
	var move_queue = [ start_loc ]
	var visited = { start_loc : _init_move_state(1, start_dir, [ start_loc ]) }
	var next_move = {}
	
	for move_count in range(max_moves - 1):
		_search_move_action(move_queue, visited, next_move)
		
		for next_pos in next_move:
			if !visited.has(next_pos):
				visited[next_pos] = next_move[next_pos]
		
		move_queue = next_move.keys()
	
	## don't copy next_move->visited on the final move
	_search_move_action(move_queue, visited, next_move)
	
	return visited

## Starting at the unit's current position, we want to search through all possible connecting hexes that we can move to.
## We want to perform a breadth first search, and vist each new grid position only once.
func _search_move_action(move_queue, visited, next_move):
	while !move_queue.empty():
		var cur_pos = move_queue.pop_front()
		var neighbors = _visit_cell_neighbors(cur_pos, visited, next_move)
		for next_pos in neighbors:
			visited[next_pos] = neighbors[next_pos]
			move_queue.push_back(next_pos)

func _visit_cell_neighbors(cur_pos, visited, next_move):
	var next_visited = {}
	
	var parity = int(cur_pos.y) & 1
	
	var cur_state = visited[cur_pos]
	var facing = cur_state.facing
	var move_count = cur_state.move_count
	var hazard = cur_state.hazard
	
	for move_dir in HexUtils.MOVE_DIRECTIONS[facing]:
		## unpack the current state
		var move_remaining = cur_state.move_remaining
		var turn_remaining = cur_state.turn_remaining
		
		## get the destination pos
		var move_step = HexUtils.HEX_CONN[parity][move_dir]
		var next_pos = cur_pos + move_step

		if visited.has(next_pos):
			continue ## already visited
		
		if not _can_enter(next_pos):
			continue ## can't go this direction, period
		
		var extra_move = false #if we need to start a new move action to visit the next_pos
		
		## handle turning costs
		var turn_cost = 0
		if _track_turns:
			turn_cost = abs(HexUtils.get_shortest_turn(facing, move_dir))
			
			## do we need to start a new move to face this direction?
			if turn_remaining < turn_cost:
				extra_move = true
				move_remaining = 0 #movement only carries over if we are able to make the turn
		
		## handle movement costs
		var move_cost = _move_cost(cur_pos, next_pos)
		
		## do we need to start a new move to make it to the next_pos?
		if move_remaining < move_cost:
			extra_move = true
		
		#print("%s: %s[%s] -> %s[%s] : turn %s/%s, move %s/%s : %s" % [move_count, cur_pos, facing, next_pos, move_dir, turn_cost, turn_remaining, move_cost, move_remaining, !extra_move])
		var next_path = cur_state.path.duplicate()
		next_path.push_back(next_pos)		
		
		## visit the next_pos
		if !extra_move:
			## continue the current move action
			var next_state = cur_state.duplicate()
			
			next_state.facing = move_dir
			next_state.move_remaining -= move_cost
			if _track_turns:
				next_state.turn_remaining -= turn_cost
			next_state.hazard = hazard || _is_dangerous(next_pos)
			next_state.path = next_path
		
			next_visited[next_pos] = next_state
		else:
			## even if we take a whole new move action, we still may not be able to reach the next_pos, so check that
			if _movement_rate + move_remaining >= move_cost && (!_track_turns || _turning_rate + turn_remaining >= turn_cost):
				var next_state = _init_move_state(move_count + 1, move_dir, next_path)
				
				## carry over remaining movement
				next_state.move_remaining += move_remaining - move_cost
				if _track_turns:
					## turns don't carry over. however we can use the remaining turns to pay off any remaining cost.
					next_state.turn_remaining += min(turn_remaining - turn_cost, 0)
				next_state.hazard = hazard || _is_dangerous(next_pos)
				
				next_move[next_pos] = next_state
	
	return next_visited


## Figure out if the unit can enter the given cell position
func _can_enter(cell_pos):
	return true #TODO

## we may be able to enter but not finish our movement in certain cells
func _can_stop(cell_pos):
	return true #TODO

## How much movement must we expend to move from a cell in a given direction?
func _move_cost(from_pos, to_pos):
	return _grid_spacing #TODO

## If entering a given cell will trigger a dangerous terrain check
func _is_dangerous(cell_pos):
	return false #TODO

func free_rotate():
	return !_track_turns