extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")
const RoadSegment = preload("res://scripts/terrain/RoadSegment.tscn")
const PriorityQueue = preload("res://scripts/helpers/PriorityQueue.gd")

var world_map

var _segments = []
var _placed_cells = {}

func _init(world_map):
	self.world_map = world_map

func build_segments(road_map):
	_generate_segments(road_map)
	
	_merge_or_join_segments()
	
	for segment in _segments.duplicate():
		segment.build_points()
		if segment.points.size() <= 1:
			_segments.erase(segment)
			segment.queue_free()
	
	return _segments

func _get_neighbors(segment, cell_pos):
	var connections = {}
	var conn_dir = {}
	var neighbors = HexUtils.get_neighbors(cell_pos)
	for next_dir in neighbors:
		var next_pos = neighbors[next_dir]
		if _placed_cells.has(next_pos):
			var other = _placed_cells[next_pos]
			var can_connect = false
			if segment == null:
				## segment is null, so we are looking for neighbors that can extend to the currently unoccupied cell_pos
				can_connect = other.can_extend(next_pos, cell_pos)
			else:
				## segment isn't null, so we are looking for neighbors to merge or join.
				can_connect = segment != other ## can't merge or join with ourselves
				
			if can_connect:
				connections[next_pos] = other
				conn_dir[next_pos] = HexUtils.reverse_dir(next_dir)
	
	return {
		connections = connections,
		dirs = conn_dir,
	}

func _generate_segments(road_map):
	for cell_pos in road_map.get_used_cells():
		
		## see if there are any existing segments to connect to
		var candidate_info = _get_neighbors(null, cell_pos)
		var candidates = candidate_info.connections
		var candidates_dir = candidate_info.dirs
		
		if !candidates.empty():
			## connect to existing segment
			var comparer = RoadConnectionComparer.new(cell_pos, candidates, candidates_dir)
			var best = SortingUtils.get_min_item(candidates.keys(), comparer, "compare")
			
			var existing_segment = candidates[best]
			existing_segment.extend(best, cell_pos)
			_placed_cells[cell_pos] = existing_segment
		else:
			var new_segment = RoadSegment.instance()
			new_segment.setup(world_map, cell_pos)
			_segments.push_back(new_segment)
			_placed_cells[cell_pos] = new_segment

func _merge_or_join_segments():
	var merge_info = {}
	var merge_queue = PriorityQueue.new()
	for segment in _segments:
		for cell_pos in segment.get_endpoints():
			var candidate_info = _get_neighbors(segment, cell_pos)
			if !candidate_info.connections.empty():
				merge_info[cell_pos] = candidate_info
				merge_queue.add(cell_pos, -candidate_info.connections.size())
	
	while !merge_queue.empty():
		var next_pos = merge_queue.pop_min()
		if !merge_info.has(next_pos):
			continue
		
		var segment = _placed_cells[next_pos]
		var merged = _possibly_merge(segment, next_pos, merge_info[next_pos])
		if merged != null:
			for old_pos in merged.footprint:
				_placed_cells[old_pos] = segment
			
			for endpoint in merged.get_endpoints():
				if !segment.get_endpoints().has(endpoint):
					merge_info.erase(endpoint)
			
			_segments.erase(merged)
			merged.queue_free()

func _possibly_merge(segment, cell_pos, candidate_info):
	## see if there are any neighboring segments we can connect to
	var candidates = candidate_info.connections
	var candidate_dir = candidate_info.dirs
		
	var comparer = RoadConnectionComparer.new(cell_pos, candidates, candidate_dir)
	var best_pos = SortingUtils.get_min_item(candidates.keys(), comparer, "compare")
		
	var other = _placed_cells[best_pos]
	if segment.can_merge(other, cell_pos, best_pos):
		segment.merge(other, cell_pos, best_pos)
		return other
	
	## just form a junction
	segment.extend(cell_pos, best_pos)
	other.join(best_pos, cell_pos, segment)
	return null

## determines how roads connect by ordering available connections
class RoadConnectionComparer:
	var cell_pos
	var neighbors #map neighbor_pos -> segment
	var join_angle = {}
	func _init(cell_pos, neighbors, neighbor_dir): 
		if cell_pos == Vector2(27,15):
			print("breakpoint")
		self.cell_pos = cell_pos
		self.neighbors = neighbors
		
		for next_pos in neighbors:
			var min_angle = null
			var neighbor = neighbors[next_pos]
			for existing_dir in neighbor.all_connection_dirs(next_pos):
				var angle = abs(HexUtils.get_shortest_turn(existing_dir, neighbor_dir[next_pos]))
				if min_angle == null || angle < min_angle:
					min_angle = angle
			join_angle[next_pos] = min_angle
	
	func compare(pos_left, pos_right):
		return SortingUtils.lexical_sort(
			_conn_lexical(neighbors[pos_left], pos_left), _conn_lexical(neighbors[pos_right], pos_right)
		)
	
	func _conn_lexical(segment, next_pos):
		if cell_pos == Vector2(27,15):
			print(next_pos, ": ", abs(2 - segment.total_connections(next_pos)))
			print(next_pos, ": ", join_angle[next_pos] if join_angle != null else 100)
		return [
			abs(2 - segment.total_connections(next_pos)), 
			join_angle[next_pos] if join_angle != null else 100,
		]