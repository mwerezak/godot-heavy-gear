## Interpolates unit grid elevation from terrain hex elevation
extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var world_map

## these are mapped using offset coords
var _bounds = [{}, {}]
var _elevation_map = {}

var _info_cache = {}

func _init(world_map):
	self.world_map = world_map

func load_elevation_map(raw_elevation):
	_elevation_map.clear()
	_bounds[0].clear()
	_bounds[1].clear()
	for offset_cell in world_map.terrain_tiles.values():
		_elevation_map[offset_cell] = raw_elevation[offset_cell] if raw_elevation.has(offset_cell) else 0
		_update_bounds(_COL, offset_cell.x, offset_cell.y)
		_update_bounds(_ROW, offset_cell.y, offset_cell.x)

const _COL = 0
const _ROW = 1
const _MIN = 0
const _MAX = 1
func _update_bounds(axis, index, value):
	if _bounds[axis].has(index):
		var bounds = _bounds[axis][index]
		bounds[_MIN] = min(bounds[_MIN], value)
		bounds[_MAX] = max(bounds[_MAX], value)
	else:
		_bounds[axis][index] = [ value, value ]

func _clamp_bounds(value, axis, index):
	var bounds = _bounds[axis][index]
	return clamp(value, bounds[_MIN], bounds[_MAX])

func _get_terrain_elevation(terrain_cell):
	var hex_cell = world_map.terrain_grid.axial_to_offset(terrain_cell)
	if !_bounds[_COL].has(hex_cell.x) && !_bounds[_ROW].has(hex_cell.y):
		return null
	
	## repeated boundary conditions
	elif !_bounds[_ROW].has(hex_cell.y):
		hex_cell.y = _clamp_bounds(hex_cell.y, _COL, hex_cell.x)
		hex_cell.x = _clamp_bounds(hex_cell.x, _ROW, hex_cell.y)
	else:
		hex_cell.x = _clamp_bounds(hex_cell.x, _ROW, hex_cell.y)
		hex_cell.y = _clamp_bounds(hex_cell.y, _COL, hex_cell.x)
	
	return _elevation_map[hex_cell]

## each trapezoid consists of an upper triangle (x>y) and a lower triangle (y>x)
const _UPPER_TRIANGLE = 0
const _LOWER_TRIANGLE = 1
const TRAPEZOID = [
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
]
func _calc_plane_coefficients(terrain_origin):
	## get the elevation at each corner of the trapezoid
	var trapezoid = TRAPEZOID.duplicate()
	for i in range(4):
		var terrain_cell = terrain_origin + trapezoid[i]
		var elevation = _get_terrain_elevation(terrain_cell)
		if elevation == null:
			return null
		
		## x,y are in pixels, so it's probably a good idea
		## to make all components have consistent units
		var z = HexUtils.units2pixels(elevation)
		
		var world_pos = world_map.terrain_grid.axial_to_world(terrain_cell)
		trapezoid[i] = Vector3(world_pos.x, world_pos.y, z)
	
	return [
		_calc_plane(trapezoid[0], trapezoid[1], trapezoid[2]), #upper triangle
		_calc_plane(trapezoid[0], trapezoid[2], trapezoid[3]), #lower triangle
	]

func _calc_plane(plane_origin, p1, p2):
	var plane_normal = (p1 - plane_origin).cross(p2 - plane_origin)
	return [ plane_normal.x, plane_normal.y, plane_normal.z, -plane_normal.dot(plane_origin) ]

func _calc_elevation_info(grid_cell):
	## get the elevation trapezoid containing cell_pos
	var world_pos = world_map.unit_grid.axial_to_world(grid_cell)
	var axial_pos = world_map.terrain_grid.world_to_axial(world_pos)
	var origin_hex = axial_pos.floor()
	
	var plane = _calc_plane_coefficients(origin_hex)
	if !plane:
		return null
	
	var local_pos = axial_pos - origin_hex #position within the trapezoid
	if local_pos.x > local_pos.y:
		plane = plane[_UPPER_TRIANGLE]
	else:
		plane = plane[_LOWER_TRIANGLE]
	
	# ax + by + cz + d = 0 --> z = -(ax + by + d)/c
	var z = -(plane[0]*world_pos.x + plane[1]*world_pos.y + plane[3])/plane[2]
	
	return {
		level = HexUtils.pixels2units(z),
		world_pos = world_pos,
		true_pos = HexUtils.pixels2units(Vector3(world_pos.x, world_pos.y, z)), #true position in distance units
		grade = Vector2(plane[0], plane[1])/plane[2], #gradient = (dz/dx, dz/dy)
		normal = Vector3(plane[0], plane[1], plane[2]).normalized(),
	}

var _unsmoothed = {}

const SHARPNESS = 0.2 #controls how much we smooth the elevation map
func get_info(grid_cell):
	if _info_cache.has(grid_cell):
		return _info_cache[grid_cell]
	
	if !_unsmoothed.has(grid_cell):
		_unsmoothed[grid_cell] = _calc_elevation_info(grid_cell)
	
	var info = _unsmoothed[grid_cell]
	if info:
		## average with neighbors
		var neighbors = HexUtils.get_axial_neighbors(grid_cell).values()
		var total = SHARPNESS*neighbors.size()
		for neighbor_cell in neighbors:
			if !_unsmoothed.has(neighbor_cell):
				_unsmoothed[neighbor_cell] = _calc_elevation_info(neighbor_cell)
			var neighbor_info = _unsmoothed[neighbor_cell]
			if neighbor_info:
				info.level = (total*info.level + neighbor_info.level)/(total+1)
				info.grade = (total*info.grade + neighbor_info.grade)/(total+1)
				info.normal = (total*info.normal + neighbor_info.normal)/(total+1)
				total += 1
	
	_info_cache[grid_cell] = info
	return info

