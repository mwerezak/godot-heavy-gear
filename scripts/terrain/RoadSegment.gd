extends Line2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var world_map

var start_position
var end_position

## cell positions this road segment lies on
## maps cell_pos -> array of dirs connecting to THIS road segment
var footprint = {}

## maps cell position -> dict of dirs connecting to OTHER road segments
var junctions = {}

func setup(world_map, start_cell_pos):
	self.world_map = world_map
	start_position = start_cell_pos
	end_position = start_cell_pos
	footprint[start_cell_pos] = []

func build_points():
	if footprint[start_position].size() != 1:
		return
	
	add_point(Vector2())
	position = world_map.get_grid_pos(start_position)
	
	var fwd_dir = footprint[start_position][0]
	var cur_pos = HexUtils.get_step(start_position, fwd_dir)
	while fwd_dir != null:
		add_point(world_map.get_grid_pos(cur_pos) - position)

		var rev_dir = HexUtils.reverse_dir(fwd_dir)
		fwd_dir = null
		for next_dir in footprint[cur_pos]:
			if next_dir != rev_dir:
				fwd_dir = next_dir
				cur_pos = HexUtils.get_step(cur_pos, fwd_dir)
				break
	

func can_extend(cell_pos, new_pos):
	if !footprint.has(cell_pos):
		return false
	
	if footprint[cell_pos].size() >= 2:
		return false
	
	return true

func extend(cell_pos, new_pos):
	assert(HexUtils.get_neighbors(cell_pos).values().has(new_pos))
	
	var dir = world_map.get_dir_to(cell_pos, new_pos)
	footprint[cell_pos].push_back(dir)
	footprint[new_pos] = [ HexUtils.reverse_dir(dir) ]
	if cell_pos == end_position:
		end_position = new_pos
	elif cell_pos == start_position:
		start_position = new_pos

func join(cell_pos, new_pos, segment):
	var dir = world_map.get_dir_to(cell_pos, new_pos)
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
	var dir = world_map.get_dir_to(cell_pos, new_pos)
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