extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")
const RoadSegment = preload("res://scripts/terrain/RoadSegment.gd")

var world_map

var _segments = []
var _placed_cells = {}

func _init(world_map):
	self.world_map = world_map

func build_segments(road_map):
	_generate_segments(road_map)
	
	for segment in _segments.duplicate():
		_possibly_merge_segment(segment)
	
	for segment in _segments:
		segment.build_points()
		if segment.points.size() > 0:
			world_map.add_child(segment)

func _generate_segments(road_map):
	for cell_pos in road_map.get_used_cells():
		
		if cell_pos == Vector2(32, 37):
			print("breakpoint")
		
		## see if there are any existing segments to connect to
		var connections = {}
		var conn_dir = {}
		var neighbors = HexUtils.get_neighbors(cell_pos)
		for next_dir in neighbors:
			var next_pos = neighbors[next_dir]
			if _placed_cells.has(next_pos):
				var segment = _placed_cells[next_pos]
				connections[next_pos] = segment
				conn_dir[next_pos] = HexUtils.reverse_dir(next_dir)
		
		if !connections.empty():
			## prefer to connect to segments that have fewer existing connections
			var candidates = connections.keys()
			var comparer = RoadConnectionComparer.new(cell_pos, connections, conn_dir)
			var best = SortingUtils.get_min_item(candidates, comparer, "compare")
			
			var existing_segment = connections[best]
			if existing_segment.can_extend(best, cell_pos):
				existing_segment.extend(best, cell_pos)
				_placed_cells[cell_pos] = existing_segment
			else:
				var new_segment = RoadSegment.new()
				new_segment.setup(world_map, cell_pos)
				new_segment.extend(cell_pos, best)
				_segments.push_back(new_segment)
				_placed_cells[cell_pos] = new_segment
				
				existing_segment.join(best, cell_pos, new_segment)
		else:
			var new_segment = RoadSegment.new()
			new_segment.setup(world_map, cell_pos)
			_segments.push_back(new_segment)
			_placed_cells[cell_pos] = new_segment

func _possibly_merge_segment(segment):
	var merged = true
	while merged:
		merged = false
		for cell_pos in [segment.start_position, segment.end_position]:
			## see if there are any neighboring segments we can connect to
			for next_pos in HexUtils.get_neighbors(cell_pos).values():
				if !_placed_cells.has(next_pos):
					continue
					
				var other = _placed_cells[next_pos]
				if other != segment:
					if segment.can_merge(other, cell_pos, next_pos):
						segment.merge(other, cell_pos, next_pos)
						for old_pos in other.footprint:
							_placed_cells[old_pos] = segment
						_segments.erase(other)
						other.queue_free()
						merged = true
					elif _placed_cells[cell_pos] == segment:
						segment.extend(cell_pos, next_pos)
						other.join(next_pos, cell_pos, segment) 

class RoadConnectionComparer:
	var cell_pos
	var neighbors
	var join_angle = {}
	func _init(cell_pos, neighbors, neighbor_dir): 
		self.cell_pos = cell_pos
		self.neighbors = neighbors
		
		for next_pos in neighbors:
			var neighbor = neighbors[next_pos]
			var conn_dirs = neighbor.footprint[next_pos]
			if conn_dirs.size() == 1:
				var existing_dir = conn_dirs.front()
				join_angle[neighbor] = abs(HexUtils.get_shortest_turn(existing_dir, neighbor_dir[next_pos]))
	
	func compare(pos_left, pos_right):
		return SortingUtils.lexical_sort(
			_conn_lexical(neighbors[pos_left], pos_left), _conn_lexical(neighbors[pos_right], pos_right)
		)
	
	func _conn_lexical(segment, next_pos):
		return [
			segment.total_connections(next_pos), 
			join_angle[next_pos] if join_angle.has(next_pos) else 100,
		]