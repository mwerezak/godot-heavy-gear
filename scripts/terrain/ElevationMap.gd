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
	if !_bounds[_ROW].has(hex_pos.x) || !_bounds[_COL].has(hex_pos.y):
		return null
	
	## repeated boundary conditions
	hex_pos.x = _clamp_bounds(hex_pos.x, _ROW, hex_pos.y)
	hex_pos.y = _clamp_bounds(hex_pos.y, _COL, hex_pos.x)
	return _elevation_map[hex_pos]

## elevation grid points are in the center of each terrain hex
func _world_to_axial(world_pos):
	return terrain_grid.world_to_axial(world_pos - terrain_grid.cell_size/2.0)

func _axial_to_world(axial_pos):
	return terrain_grid.axial_to_world(axial_pos) + terrain_grid.cell_size/2.0

## returns [UL, UR, LR, LL] <-> [ f11, f12, f22, f21 ]
func _get_trapezoid(trap_origin):
	var trap_origin_world = _axial_to_world(trap_origin)
	var origin_hex = world_map.get_terrain_hex(trap_origin_world)
	return [ origin_hex, HexUtils.get_step(origin_hex, 0), HexUtils.get_step(origin_hex, 2), HexUtils.get_step(origin_hex, 4) ]

func get_elevation(world_pos):
	## get the elevation trapezoid containing world_pos
	var axial_pos = _world_to_axial(world_pos)
	var trap_origin = axial_pos.floor()
	var trap = _get_trapezoid(trap_origin)
	
	## get the elevation at each corner of the trapezoid
	var z = [0, 0, 0, 0]
	for i in range(4):
		z[i] = _get_hex_elevation(trap[i])
	
	if z.has(null):
		return z[0]
	
	## calculate bilinear coefficients
	var a = [0, 0, 0, 0]
	a[0] = z[0]
	a[1] = z[3] - z[0]
	a[2] = z[1] - z[0]
	a[3] = z[0] - z[1] + z[2] - z[3]
	
	## bilinear interpolation
	var v = axial_pos - trap_origin
	#return a[0] + a[1]*v.x + a[2]*v.y + a[3]*v.x*v.y
	var z_y0 = lerp(z[0], z[1], v.x)
	var z_y1 = lerp(z[3], z[2], v.x)
	return lerp(z_y0, z_y1, v.y)


"""
func _init(world_map):
	self.world_map = world_map
	axial_xform = HexUtils.get_axial_transform().scaled(terrain_cell_size)
	axial_xform_inv = axial_xform.affine_inverse()
	
	## get the hex boundaries
	var map_bounds = world_map.get_bounding_rect()
	var start = world_map.get_terrain_hex(map_bounds.position)
	var end = world_map.get_terrain_hex(map_bounds.end)
	hex_bounds = [ start, end ]

func load_hex_map(hex_elevation):
	_cache.clear()
	self.hex_elevation = hex_elevation

func get_elevation_at_cell(cell_pos):
	if !_cache.has(cell_pos):
		_cache[cell_pos] = _calc_elevation(cell_pos)
	return _cache[cell_pos].elevation

func get_gradient_at_cell(cell_pos):
	if !_cache.has(cell_pos):
		_cache[cell_pos] = _calc_elevation(cell_pos)
	return _cache[cell_pos].gradient

func _calc_elevation(cell_pos):
	var world_pos = world_map.get_grid_pos(cell_pos)
	var hex_pos = world_map.get_terrain_hex(world_pos)
	var axial_pos = axial_xform_inv.xform(world_pos + terrain_cell_size/2)
	var upper_left_axial = Vector2(floor(axial_pos.x), floor(axial_pos.y))
	
	var a = _get_bilinear_coefficients(upper_left_axial)
	var v = axial_pos - upper_left_axial
	return {
		elevation = a[0] + a[1]*v.x + a[2]*v.y + a[3]*v.x*v.y,
		gradient = Vector2(a[1] + a[3]*v.y, a[2] + a[3]*v.x),
	}

func _get_bilinear_coefficients(axial_pos):
	var Q = _eval_trapezoid_corners(_get_hex_pos(axial_pos))
	
	## bilinear transform
	var a0 = Q[0]
	var a1 = Q[2] - Q[0]
	var a2 = Q[1] - Q[0]
	var a3 = Q[0] - Q[1] - Q[2] + Q[3]
	return [ a0, a1, a2, a3 ]

func _eval_trapezoid_corners(upper_left_hex):
	var ul = upper_left_hex
	var ur = HexUtils.get_step(upper_left_hex, 4)
	var ll = HexUtils.get_step(upper_left_hex, 0)
	var lr = HexUtils.get_step(upper_left_hex, 2)
	return [
		_get_raw_elevation(ul),
		_get_raw_elevation(ur),
		_get_raw_elevation(ll),
		_get_raw_elevation(lr),
	]

func _get_raw_elevation(hex_pos):
	## boundary conditions
	hex_pos.x = clamp(hex_pos.x, hex_bounds[0].x, hex_bounds[1].x)
	hex_pos.y = clamp(hex_pos.y, hex_bounds[0].y, hex_bounds[1].y)
	return hex_elevation[hex_pos] if hex_elevation.has(hex_pos) else 0

func _get_hex_pos(axial_pos):
	var world_pos = axial_xform.xform(axial_pos) - terrain_cell_size/2
	return world_map.get_terrain_hex(world_pos)
"""