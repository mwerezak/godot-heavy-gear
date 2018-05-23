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

var _info_cache = {}

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

const _UPPER_TRIANGLE = 0
const _LOWER_TRIANGLE = 1
func _calc_plane_coefficients(origin_hex):
	## each trapezoid consists of an upper triangle (x>y) and a lower triangle (y>x)
	var trap_hexes = [ origin_hex, HexUtils.get_step(origin_hex, 0), HexUtils.get_step(origin_hex, 2), HexUtils.get_step(origin_hex, 4) ]
	## get the elevation at each corner of the trapezoid
	var trap_vec = [null, null, null, null]
	for i in range(4):
		var elevation = _get_hex_elevation(trap_hexes[i])
		if elevation == null:
			return null
		
		## x,y are in pixels, so it's probably a good idea
		## to make all components have consistent units
		var z = HexUtils.units2pixels(elevation)
		
		var pos = world_map.get_terrain_pos(trap_hexes[i])
		trap_vec[i] = Vector3(pos.x, pos.y, z)
	
	return [
		_calc_plane(trap_vec[0], trap_vec[1], trap_vec[2]), #upper triangle
		_calc_plane(trap_vec[0], trap_vec[2], trap_vec[3]), #lower triangle
	]

func _calc_plane(plane_origin, p1, p2):
	var plane_normal = (p1 - plane_origin).cross(p2 - plane_origin)
	return [ plane_normal.x, plane_normal.y, plane_normal.z, -plane_normal.dot(plane_origin) ]

func _calc_elevation_info(cell_pos):
	## get the elevation trapezoid containing cell_pos
	var world_pos = world_map.get_grid_pos(cell_pos)
	var axial_pos = _world_to_axial(world_pos)
	var trap_origin = axial_pos.floor()
	var origin_hex = world_map.get_terrain_hex(_axial_to_world(trap_origin))
	
	var plane = _calc_plane_coefficients(origin_hex)
	if !plane:
		return null
	
	var trap_pos = axial_pos - trap_origin #axial position within the trapezoid
	if trap_pos.x > trap_pos.y:
		plane = plane[_UPPER_TRIANGLE]
	else:
		plane = plane[_LOWER_TRIANGLE]
	
	# ax + by + cz + d = 0 --> z = -(ax + by + d)/c
	var z = -(plane[0]*world_pos.x + plane[1]*world_pos.y + plane[3])/plane[2]
	
	return {
		level = HexUtils.pixels2units(z),
		world_pos = Vector3(world_pos.x, world_pos.y, z),
		grade = Vector2(plane[0], plane[1])/plane[2], #gradient = (dz/dx, dz/dy)
		normal = Vector3(plane[0], plane[1], plane[2]).normalized(),
	}

func get_info(cell_pos):
	if _info_cache.has(cell_pos):
		return _info_cache[cell_pos]
	
	var info = _calc_elevation_info(cell_pos)
	_info_cache[cell_pos] = info
	return info
