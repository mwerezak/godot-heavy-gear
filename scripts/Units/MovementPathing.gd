## Generates all possible movement for a unit and stores this information for display and pathing.

extends Reference

const WorldMap = preload("res://scripts/WorldMap.gd")

const HexUtils = preload("res://scripts/HexUtils.gd")
const MovementModes = preload("res://scripts/Game/MovementModes.gd")
const PriorityQueue = preload("res://scripts/DataStructures/PriorityQueue.gd")

static func calculate_movement(world_map, move_unit, max_moves=2, start_loc=null, start_dir=null):
	start_loc = start_loc if start_loc else move_unit.cell_position
	start_dir = start_dir if start_dir else move_unit.facing
	
	var unit_info = move_unit.unit_info
	
	var movement_modes = []
	for mode in unit_info.get_movement_modes():
		movement_modes.push_back([mode, false])
		if unit_info.get_reverse_speed(mode):
			movement_modes.push_back([mode, true])
	
	## calculate pathing for each movement mode and then merge the results
	var possible_moves = {}
	for item in movement_modes:
		var movement_mode = item[0]
		var reverse = item[1]
		
		var movement = new(world_map, move_unit, movement_mode, max_moves, reverse, start_loc, start_dir)
		for cell_pos in movement.possible_moves:
			var move_info = movement.possible_moves[cell_pos]
			
			## hack in some additional info
			move_info.movement_mode = movement_mode
			if move_info.reverse:
				move_info.facing = HexUtils.reverse_dir(move_info.facing)
			
			if !possible_moves.has(cell_pos) || _prefer_move(possible_moves[cell_pos], move_info):
				possible_moves[cell_pos] = move_info
	return possible_moves

static func _prefer_move(old_move, new_move):
	if old_move.hazard && !new_move.hazard:
		return true #always pick non-hazardous moves over hazardous ones
	if !old_move.free_rotate && new_move.free_rotate:
		return true
	if old_move.turn_remaining != new_move.move_remaining:
		var old_turn = old_move.turn_remaining if old_move.turn_remaining != null else 1000
		var new_turn = new_move.turn_remaining if new_move.turn_remaining != null else 1000
		return old_turn < new_turn
	if old_move.move_count != new_move.move_count:
		return old_move.move_count > new_move.move_count
	return old_move.move_remaining < new_move.move_remaining

var move_unit #the unit whose movement we are considering
var unit_info
var world_map #reference to the world map the unit is located on
var movement_type #movement type to use, since units may have more than one

var reverse
var _track_turns #flag if we should track facing and turn rate

## a dictionary of the grid positions this unit can reach from the start_loc
## each position is mapped to a dictionary of information (e.g. movement costs, facing at that hex, turning angle used)
var possible_moves = {}

## cached data
var _grid_spacing
var _movement_rate #amount of movement per move action
var _turning_rate  #amount of turning per move action

func _init(world_map, unit, movement_type, max_moves, reverse, start_loc, start_dir):
	self.move_unit = unit
	self.unit_info = unit.unit_info
	self.world_map = world_map
	self.movement_type = movement_type
	self.reverse = reverse
	
	_grid_spacing = HexUtils.pixels2units(world_map.UNITGRID_WIDTH)
	
	_movement_rate = unit_info.get_move_speed(movement_type)
	_turning_rate = unit_info.get_turn_rate(movement_type)
	_track_turns = unit_info.use_facing() && _turning_rate != null
	
	if reverse:
		start_dir = HexUtils.reverse_dir(start_dir)
		_movement_rate = unit_info.get_reverse_speed(movement_type)
	
	var visited = _search_possible_moves(start_loc, start_dir, max_moves)
	for cell_pos in visited:
		if cell_pos != start_loc && _can_stop(cell_pos):
			possible_moves[cell_pos] = visited[cell_pos]


## setups a movement state for the beginning of a move action
func _init_move_state(move_count, facing, move_path):
	return {
		move_count = move_count,
		facing = facing,
		prev_facing = null,
		free_rotate = !_track_turns,
		reverse = reverse,
		move_remaining = _movement_rate,
		turn_remaining = _turning_rate,
		hazard = false,
		path = move_path,
	}

## lower priority moves are explored first
func _move_priority(move_state):
	var turns = move_state.turn_remaining if move_state.turn_remaining else 0
	var moves = move_state.move_remaining
	var hazard = 10000 if move_state.hazard else 0
	return -(turns * 10*moves) + hazard

func _search_possible_moves(start_loc, start_dir, max_moves):
	var visited = { start_loc : _init_move_state(1, start_dir, [ start_loc ]) }
	var next_move = {}
	
	var move_queue = PriorityQueue.new()
	move_queue.add(start_loc, _move_priority(visited[start_loc]))
	
	for move_count in range(max_moves - 1):
		_search_move_action(move_queue, visited, next_move)
		
		## add the next move start positions to the queue
		assert(move_queue.size() == 0)
		for next_pos in next_move:
			if !visited.has(next_pos):
				visited[next_pos] = next_move[next_pos]
			move_queue.add(next_pos, _move_priority(visited[next_pos]))
	
	## don't use any of the positions in next_move on the final move
	_search_move_action(move_queue, visited, next_move)
	
	return visited

## Starting at the unit's current position, we want to search through all possible connecting hexes that we can move to.
## We want to perform a breadth first search, and vist each new grid position only once.
func _search_move_action(move_queue, visited, next_move):
	while !move_queue.empty():
		var cur_pos = move_queue.pop_min()
		var neighbors = _visit_cell_neighbors(cur_pos, visited, next_move)
		for next_pos in neighbors:
			visited[next_pos] = neighbors[next_pos]
			move_queue.add(next_pos, _move_priority(neighbors[next_pos]))

func _visit_cell_neighbors(cur_pos, visited, next_move):
	var next_visited = {}
	
	## unpack current state
	var cur_state = visited[cur_pos]
	var facing = cur_state.facing
	var prev_facing = cur_state.prev_facing
	var move_count = cur_state.move_count
	var hazard = cur_state.hazard
	
	var neighbors = HexUtils.get_neighbors(cur_pos)
	for move_dir in neighbors:
		var next_pos = neighbors[move_dir]
		var move_remaining = cur_state.move_remaining
		var turn_remaining = cur_state.turn_remaining
		
		if visited.has(next_pos):
			continue ## already visited
		
		if not _can_enter(cur_pos, next_pos):
			continue ## can't go this direction, period
		
		var extra_move = false #if we need to start a new move action to visit the next_pos
		
		## handle turning costs
		var turn_cost = 0
		if _track_turns:
			turn_cost = abs(HexUtils.get_shortest_turn(facing, move_dir))
			
			## if we return to our previous facing, refund the turn cost
			## this allows "straight" zig-zagging, which hopefully lessens 
			## the distortion on movement caused by using a hex grid
			if move_dir == prev_facing:
				turn_cost *= -1
			
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
			next_state.prev_facing = facing
			next_state.move_remaining -= move_cost
			if _track_turns:
				next_state.turn_remaining -= turn_cost
			next_state.hazard = hazard || _is_dangerous(next_pos)
			next_state.path = next_path
		
			next_visited[next_pos] = next_state
		else:
			## even if we take a whole new move action, we still may not be able to reach the next_pos, so check that
			if _movement_rate + move_remaining >= move_cost && (!_track_turns || _turning_rate + turn_remaining >= turn_cost):
				## it's important that prev_facing is cleared when we reset turns_remaining
				## that way on the next iteration we can't be refunded turns we haven't spent.
				var next_state = _init_move_state(move_count + 1, move_dir, next_path)
				
				## carry over remaining movement
				next_state.move_remaining += move_remaining - move_cost
				if _track_turns:
					## turns don't carry over. however we can use the remaining turns to pay off any remaining cost.
					next_state.turn_remaining += min(turn_remaining - turn_cost, 0)
				
				## carry over hazard flag
				next_state.hazard = hazard || _is_dangerous(next_pos)
				
				next_move[next_pos] = next_state
	
	return next_visited


## Figure out if the unit can enter the given cell position
func _can_enter(from_cell, to_cell):
	return world_map.unit_can_pass(move_unit, from_cell, to_cell)

## we may be able to enter but not finish our movement in certain cells
func _can_stop(cell_pos):
	return world_map.unit_can_place(move_unit, cell_pos)

## How much movement must we expend to move from a cell in a given direction?
func _move_cost(from_cell, to_cell):
	var midpoint = 0.5*(world_map.get_grid_pos(from_cell) + world_map.get_grid_pos(to_cell))
	var terrain_info = world_map.get_terrain_at(midpoint)
	return _grid_spacing * unit_info.get_move_cost_on_terrain(movement_type, terrain_info)

## If entering a given cell will trigger a dangerous terrain check
func _is_dangerous(cell_pos):
	return false #TODO
