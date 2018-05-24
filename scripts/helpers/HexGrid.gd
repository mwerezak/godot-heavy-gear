extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

## the width,height size of hexagonal cells in the grid
export(Vector2) var cell_size = Vector2() setget set_cell_size

## the horizontal and vertical separation between corresponding points in neighboring cells
var cell_spacing

var axial_transform
var square_transform #used for offset coords

func _ready():
	pass

func set_cell_size(size):
	## necessary for compatibility with TileMap
	assert(int(cell_size.x) % 2 == 0)
	assert(int(cell_size.y) % 4 == 0)

	cell_size = size
	cell_spacing = Vector2(cell_size.x, cell_size.y*3/4)
	axial_transform = _calc_axial_transform(cell_spacing)
	square_transform = _calc_square_transform(cell_spacing)

## obtains the cell containing a given world position: in axial, offset, and world flavours
func get_axial_cell(world_pos):
	var axial_pos = world_to_axial(world_pos)
	return (axial_pos + Vector2(0.5, 0.5)).floor()

func get_offset_cell(world_pos):
	var offset_pos = world_to_offset(world_pos)
	return (offset_pos + Vector2(0.5, 0.5)).floor()

func snap_to_grid(world_pos):
	var axial_pos = get_axial_cell(world_pos)
	return axial_to_world(axial_pos)

## coordinate conversions
func world_to_axial(world_pos):
	return (transform * axial_transform).affine_inverse().xform(world_pos)

func axial_to_world(axial_pos):
	return (transform * axial_transform).xform(axial_pos)

func axial_to_offset(axial_pos):
	var offset_pos = (square_transform.affine_inverse() * axial_transform).xform(axial_pos)
	var parity = int(offset_pos.y) & 1
	if parity:
		offset_pos.x -= 0.5
	return offset_pos

func offset_to_axial(offset_pos):
	var parity = int(offset_pos.y) & 1
	if parity:
		offset_pos.x += 0.5
	return (axial_transform.affine_inverse() * square_transform).xform(offset_pos)

func world_to_offset(world_pos):
	var offset_pos = (transform * square_transform).affine_inverse().xform(world_pos)
	var parity = int(offset_pos.y) & 1
	if parity:
		offset_pos.x -= 0.5
	return offset_pos

func offset_to_world(offset_pos):
	var parity = int(offset_pos.y) & 1
	if parity:
		offset_pos.x += 0.5
	return (transform * square_transform).xform(offset_pos)

static func _calc_axial_transform(cell_spacing):
	var axial_x = Vector2(cell_spacing.x, 0)
	var axial_y = Vector2(-cell_spacing.x/2, cell_spacing.y)
	return Transform2D(axial_x, axial_y, Vector2())

static func _calc_square_transform(cell_spacing):
	var cart_x = Vector2(cell_spacing.x, 0)
	var cart_y = Vector2(0, cell_spacing.y)
	return Transform2D(cart_x, cart_y, Vector2())