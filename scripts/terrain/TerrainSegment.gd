## Used to construct terrain features that follow lines on the map (roads, rivers)

extends Reference

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var segment_grid

var start_position
var end_position

## cell positions this road segment lies on
## maps cell_pos -> array of dirs connecting to THIS road segment
var footprint = {}

## maps cell position -> dict of dirs connecting to OTHER road segments
var junctions = {}

## clears all data structures to ensure no cyclic segment references
func clear():
	footprint.clear()
	junctions.clear()

func _init(segment_grid, start_cell_pos):
	self.segment_grid = segment_grid
	start_position = start_cell_pos
	end_position = start_cell_pos
	footprint[start_cell_pos] = []

## gets all cells occupied by the segment from start to end
func get_cells():
	var grid_cells = [ start_position ]
	
	if footprint[start_position].size() != 1:
		return grid_cells
	
	var fwd_dir = footprint[start_position][0]
	var cur_pos = HexUtils.get_axial_step(start_position, fwd_dir)
	while fwd_dir != null:
		grid_cells.push_back(cur_pos)
		
		var rev_dir = HexUtils.reverse_dir(fwd_dir)
		fwd_dir = null
		for next_dir in footprint[cur_pos]:
			if next_dir != rev_dir:
				fwd_dir = next_dir
				cur_pos = HexUtils.get_axial_step(cur_pos, fwd_dir)
				break
	
	#handle self-junctions
	var self_junctions = {}
	for endpoint_pos in get_endpoints():
		if junctions.has(endpoint_pos):
			for dir in junctions[endpoint_pos]:
				if junctions[endpoint_pos][dir] == self:
					var joined_pos = HexUtils.get_axial_step(endpoint_pos, dir)
					self_junctions[endpoint_pos] = joined_pos
					break
	
	if self_junctions.has(start_position):
		grid_cells.push_front(self_junctions[start_position])
	if self_junctions.has(end_position):
		grid_cells.push_back(self_junctions[end_position])
	
	return grid_cells

func get_endpoints():
	return [start_position, end_position]

func can_extend(cell_pos, new_pos):
	if !get_endpoints().has(cell_pos):
		return false
	if footprint.has(new_pos) && junctions.has(cell_pos) && junctions[cell_pos].values().has(self):
		return false #each cell may only ever have one self-junction
	return true

func extend(cell_pos, new_pos):
	assert(HexUtils.get_axial_neighbors(cell_pos).values().has(new_pos))

	var dir = segment_grid.get_axial_dir(cell_pos, new_pos)
	if footprint.has(new_pos): ## don't extend over ourselves!
		join(cell_pos, new_pos, self) ## form a self-junction instead
	else:
		footprint[cell_pos].push_back(dir)
		footprint[new_pos] = [ HexUtils.reverse_dir(dir) ]
		if cell_pos == end_position:
			end_position = new_pos
		elif cell_pos == start_position:
			start_position = new_pos

func join(cell_pos, new_pos, segment):
	var dir = segment_grid.get_axial_dir(cell_pos, new_pos)
	if !junctions.has(cell_pos):
		junctions[cell_pos] = { dir: segment }
	else:
		var junction_info = junctions[cell_pos]
		assert(!junction_info.has(dir))
		junction_info[dir] = segment

func has_junction(segment):
	for junct_info in junctions.values():
		if junct_info.values().has(segment):
			return true
	return false

func can_merge(segment, cell_pos, new_pos):
	if segment == self:
		return false
	if !can_extend(cell_pos, new_pos):
		return false
	if !segment.can_extend(new_pos, cell_pos):
		return false
	if has_junction(segment) || segment.has_junction(self):
		return false
	return true

## absorbs the given segment into this one
func merge(segment, cell_pos, new_pos):
	for other_pos in segment.footprint:
		assert(!footprint.has(other_pos))
		footprint[other_pos] = segment.footprint[other_pos]
	for other_pos in segment.junctions:
		junctions[other_pos] = segment.junctions[other_pos]
	
	## connect ends
	var dir = segment_grid.get_axial_dir(cell_pos, new_pos)
	footprint[cell_pos].push_back(dir)
	footprint[new_pos].push_back(HexUtils.reverse_dir(dir))
	
	## update endpoints
	var other_end
	if new_pos == segment.start_position:
		other_end = segment.end_position
	else:
		other_end = segment.start_position
	
	if cell_pos == start_position:
		start_position = other_end
	elif cell_pos == end_position:
		end_position = other_end

func total_connections(cell_pos):
	return footprint[cell_pos].size() + junctions[cell_pos].keys().size() if junctions.has(cell_pos) else 0

func all_connection_dirs(cell_pos):
	var dirs = footprint[cell_pos]
	if junctions.has(cell_pos):
		dirs += junctions[cell_pos].keys()
	return dirs