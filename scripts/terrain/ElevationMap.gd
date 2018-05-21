## Interpolates unit grid elevation from terrain hex elevation
extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var world_map
var terrain_cell_size
var axial_xform #xform into terrain hex axial coords
var axial_xform_inv

var hex_bounds #a 2-element array [ UL, LR ]
var hex_elevation

var _cache = {}

func _init(world_map):
	self.world_map = world_map
	terrain_cell_size = world_map.get_terrain_cell_size()
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