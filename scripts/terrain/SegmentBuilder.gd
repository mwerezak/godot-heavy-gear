extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")
const PriorityQueue = preload("res://scripts/helpers/PriorityQueue.gd")
const TerrainSegment = preload("res://scripts/terrain/TerrainSegment.gd")

var segment_grid
var connection_comparer

var _segments = []
var _placed_cells = {}

func _init(segment_grid, connection_comparer):
	self.segment_grid = segment_grid
	self.connection_comparer = connection_comparer

func build_segments(presence_map):
	_generate_segments(presence_map)
	
	_merge_or_join_segments()
	
	var rval = []
	for segment in _segments:
		var grid_cells = segment.get_cells()
		if grid_cells.size() > 1:
			rval.push_back(grid_cells)

	return rval

func _get_neighbors(segment, cell_pos):
	var connections = []
	var conn_dir = {}
	var neighbors = HexUtils.get_axial_neighbors(cell_pos)
	for next_dir in neighbors:
		var next_pos = neighbors[next_dir]
		if _placed_cells.has(next_pos):
			var other = _placed_cells[next_pos]
			if segment == null || segment != other:
				connections.push_back(next_pos)
				conn_dir[next_pos] = HexUtils.reverse_dir(next_dir)
	
	return {
		connections = connections,
		dirs = conn_dir,
	}

func _generate_segments(presence_map):
	for offset_cell in presence_map.get_used_cells():
		var cell_pos = segment_grid.offset_to_axial(offset_cell)
		
		## see if there are any existing segments to connect to
		var candidate_info = _get_neighbors(null, cell_pos)
		var connections = candidate_info.connections
		var conn_dirs = candidate_info.dirs
		
		var candidates = {}
		for grid_cell in connections:
			candidates[grid_cell] = _placed_cells[grid_cell]
		
		if !candidates.empty():
			## connect to existing segment
			var comparer = connection_comparer.new(cell_pos, candidates, conn_dirs)
			var best_pos = SortingUtils.get_min_item(candidates.keys(), comparer, "compare")
			
			var existing_segment = candidates[best_pos]
			if existing_segment.can_extend(best_pos, cell_pos):
				existing_segment.extend(best_pos, cell_pos)
				_placed_cells[cell_pos] = existing_segment
				continue
		
		var new_segment = TerrainSegment.new(segment_grid, cell_pos)
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
			merged.clear()
		
		merge_info.erase(next_pos) #mark cell as handled

func _possibly_merge(segment, cell_pos, candidate_info):
	## see if there are any neighboring segments we can connect to
	var connections = candidate_info.connections
	var conn_dirs = candidate_info.dirs
	
	var candidates = {}
	for grid_cell in connections:
		candidates[grid_cell] = _placed_cells[grid_cell]
		
	var comparer = connection_comparer.new(cell_pos, candidates, conn_dirs)
	var best_pos = SortingUtils.get_min_item(candidates.keys(), comparer, "compare")
		
	var other = _placed_cells[best_pos]
	if segment.can_merge(other, cell_pos, best_pos):
		segment.merge(other, cell_pos, best_pos)
		return other
	
	## just form a junction
	if segment.can_extend(cell_pos, best_pos):
		segment.extend(cell_pos, best_pos)
		other.join(best_pos, cell_pos, segment)
	return null
