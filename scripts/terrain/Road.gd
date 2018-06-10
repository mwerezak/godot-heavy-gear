extends Line2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var footprint

func _ready():
	z_as_relative = false
	z_index = Constants.ROAD_ZLAYER

func setup(world_map, grid_cells):
	footprint = grid_cells
	position = world_map.unit_grid.axial_to_world(footprint.front())
	for grid_cell in footprint:
		var vertex = world_map.unit_grid.axial_to_world(grid_cell) - position
		add_point(vertex)


#const DASH_LENGTH = 8
#func _create_dashes():
#	var dashes = _get_dashes(DASH_LENGTH)
#	for i in dashes.size():
#		var dash = Line2D.new()
#		dash.width = 2
#		dash.default_color = Color(1.0, 1.0, 0.5, 0.2)
#		dash.z_index = 1
#
#		for point in dashes[i]:
#			dash.add_point(point)
#
#		add_child(dash)

#func _get_dashes(pitch):
#	var dashes = []
#	var current_dash = null
#
#	var length = 0
#	var last_length = 0 #length of last_point
#	var last_point = null
#	for next_point in points:
#		if last_point:
#			var segment_length = (next_point - last_point).length()
#			var next_length = last_length + segment_length
#
#			while length < next_length:
#				var t = (length - last_length)/segment_length
#				var dash_point = last_point.linear_interpolate(next_point, t)
#				if !current_dash:
#					current_dash = [ dash_point ]
#				else:
#					current_dash.push_back(dash_point)
#					dashes.push_back(current_dash)
#					current_dash = null
#				length += pitch
#
#			if current_dash:
#				current_dash.push_back(next_point)
#
#			last_length += segment_length
#		last_point = next_point
#
#	return dashes

## determines how roads connect by ordering available connections
class ConnectionComparer:
	var cell_pos
	var neighbors #map neighbor_pos -> segment
	var join_angle = {}
	func _init(cell_pos, neighbors, neighbor_dir): 
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
		return _conn_metric(neighbors[pos_left], pos_left) < _conn_metric(neighbors[pos_right], pos_right)
	
	func _conn_metric(segment, next_pos):
		var angle = join_angle[next_pos]
		if angle != null:
			return angle
		return -segment.total_connections(next_pos)