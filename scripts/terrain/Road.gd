extends Line2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var footprint

func _ready():
	z_as_relative = false
	z_index = Constants.ROAD_ZLAYER

func setup(world_grid, grid_cells):
	footprint = grid_cells
	position = world_grid.unit_grid.axial_to_world(footprint.front())
	for grid_cell in footprint:
		var vertex = world_grid.unit_grid.axial_to_world(grid_cell) - position
		add_point(vertex)

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