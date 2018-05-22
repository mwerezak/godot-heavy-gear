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
	
	## precalculate bilinear coefficients
	_coefficients.clear()
	for hex_pos in _elevation_map:
		_get_bilinear_coefficients(hex_pos)

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

func _get_bilinear_coefficients(origin_hex):
	if _coefficients.has(origin_hex):
		return _coefficients[origin_hex]
	
	var rval = _calc_bilinear_coefficients(origin_hex)
	_coefficients[origin_hex] = rval
	return rval

func _calc_bilinear_coefficients(origin_hex):
	var trapezoid = [ origin_hex, HexUtils.get_step(origin_hex, 0), HexUtils.get_step(origin_hex, 2), HexUtils.get_step(origin_hex, 4) ]

	## get the elevation at each corner of the trapezoid
	var z = [0, 0, 0, 0]
	for i in range(4):
		z[i] = _get_hex_elevation(trapezoid[i])
	
	if z.has(null):
		return
	
	var a = [0, 0, 0, 0]
	a[0] = z[0]
	a[1] = z[1] - z[0]
	a[2] = z[3] - z[0]
	a[3] = z[0] - z[1] - z[3] + z[2]
	return a

func get_elevation(world_pos):
	## get the elevation trapezoid containing world_pos
	var axial_pos = _world_to_axial(world_pos)
	var trap_origin = axial_pos.floor()
	var origin_hex = world_map.get_terrain_hex(_axial_to_world(trap_origin))
	
	## bilinear interpolation
	var v = axial_pos - trap_origin
	var a = _get_bilinear_coefficients(origin_hex)
	if a == null:
		return _get_hex_elevation(origin_hex)
	return a[0] + a[1]*v.x + a[2]*v.y + a[3]*v.x*v.y
	#var z_y0 = lerp(z[0], z[1], v.x)
	#var z_y1 = lerp(z[3], z[2], v.x)
	#return lerp(z_y0, z_y1, v.y)
