## Interpolates unit grid elevation from terrain hex elevation
extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

const _COL = 0
const _ROW = 1
const _MIN = 0
const _MAX = 1

var world_map
var terrain_grid

var _bounds = [{}, {}]
var _elevation_map = {}
var _coefficients = {}

func _init(world_map):
	self.world_map = world_map
	self.terrain_grid = world_map.terrain

func load_hex_map(raw_elevation):
	_elevation_map.clear()
	_bounds[0].clear()
	_bounds[1].clear()
	for hex_pos in world_map.all_terrain_hexes():
		_elevation_map[hex_pos] = raw_elevation[hex_pos] if raw_elevation.has(hex_pos) else 0
		_update_bounds(_COL, hex_pos.x, hex_pos.y)
		_update_bounds(_ROW, hex_pos.y, hex_pos.x)
	
	## precalculate plane coefficients
	_coefficients.clear()
	for hex_pos in _elevation_map:
		_get_plane_coefficients(hex_pos)

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

func _get_hex_elevation(hex_pos):
	if !_bounds[_COL].has(hex_pos.x) && !_bounds[_ROW].has(hex_pos.y):
		return null
	
	## repeated boundary conditions
	elif !_bounds[_ROW].has(hex_pos.y):
		hex_pos.y = _clamp_bounds(hex_pos.y, _COL, hex_pos.x)
		hex_pos.x = _clamp_bounds(hex_pos.x, _ROW, hex_pos.y)
	else:
		hex_pos.x = _clamp_bounds(hex_pos.x, _ROW, hex_pos.y)
		hex_pos.y = _clamp_bounds(hex_pos.y, _COL, hex_pos.x)
	
	return _elevation_map[hex_pos]

## elevation grid points are in the center of each terrain hex
func _world_to_axial(world_pos):
	return terrain_grid.world_to_axial(world_pos - terrain_grid.cell_size/2.0)

func _axial_to_world(axial_pos):
	return terrain_grid.axial_to_world(axial_pos) + terrain_grid.cell_size/2.0

func _get_plane_coefficients(origin_hex):
	if _coefficients.has(origin_hex):
		return _coefficients[origin_hex]
	
	var rval = _calc_plane_coefficients(origin_hex)
	_coefficients[origin_hex] = rval
	return rval

const _UPPER_TRIANGLE = 0
const _LOWER_TRIANGLE = 1
func _calc_plane_coefficients(origin_hex):
	## each trapezoid consists of an upper triangle (x>y) and a lower triangle (y>x)
	var trap_hexes = [ origin_hex, HexUtils.get_step(origin_hex, 0), HexUtils.get_step(origin_hex, 2), HexUtils.get_step(origin_hex, 4) ]
	## get the elevation at each corner of the trapezoid
	var trap_vec = [null, null, null, null]
	for i in range(4):
		var z = _get_hex_elevation(trap_hexes[i])
		
		if z == null:
			return null
		
		var pos = world_map.get_terrain_pos(trap_hexes[i])
		trap_vec[i] = Vector3(pos.x, pos.y, z)
	
	return [
		_get_plane(trap_vec[0], trap_vec[2], trap_vec[1]), #upper triangle
		_get_plane(trap_vec[0], trap_vec[2], trap_vec[3]), #lower triangle
	]

func _get_plane(plane_origin, p1, p2):
	var plane_normal = (p1 - plane_origin).cross(p2 - plane_origin)
	return [ plane_normal.x, plane_normal.y, plane_normal.z, -plane_normal.dot(plane_origin) ]

func get_elevation(world_pos):
	## get the elevation trapezoid containing world_pos
	var axial_pos = _world_to_axial(world_pos)
	var trap_origin = axial_pos.floor()
	var origin_hex = world_map.get_terrain_hex(_axial_to_world(trap_origin))
	
	var plane = _get_plane_coefficients(origin_hex)
	if !plane:
		return _get_hex_elevation(origin_hex)
	
	var v = axial_pos - trap_origin
	if v.x > v.y:
		plane = plane[_UPPER_TRIANGLE]
	else:
		plane = plane[_LOWER_TRIANGLE]
	
	return -(plane[0]*world_pos.x + plane[1]*world_pos.y + plane[3])/plane[2]

