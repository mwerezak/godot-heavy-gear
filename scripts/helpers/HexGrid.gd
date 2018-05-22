## A tile map extended with some additional coord conversion functions specific for hex grids

extends TileMap

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

export(Vector2) var hex_size = Vector2() setget set_hex_size, get_hex_size

var _axial_transform

func _ready():
	mode = MODE_SQUARE
	cell_half_offset = HALF_OFFSET_X

func set_hex_size(hex_size):
	hex_size = hex_size
	cell_size = Vector2(hex_size.x, hex_size.y*3/4)
	_axial_transform = HexUtils.get_axial_transform(hex_size.x)

func get_hex_size():
	return hex_size

func get_cell_transform():
	assert(mode == MODE_SQUARE)
	return Transform2D(Vector2(cell_size.x, 0), Vector2(0, cell_size.y), Vector2())

func get_axial_transform():
	return _axial_transform

## NOTE: NONE of the coordinate transform functions account for the grid's own transform.
## Therefore "world" actually means "local". This may seem confusing but TileMap also works exactly
## the same way and I felt it is less confusing if these functions (which are named the same way as
## TileMap::world_to_map() and TileMap::map_to_world()) behaved the same way.

## almost like world_to_map() except we include information about where in the cell world_pos is.
func world_to_offset(world_pos):
	var map_pos = world_to_map(world_pos)
	var cell_origin = map_to_world(map_pos)
	return map_pos + get_cell_transform().affine_inverse().xform(world_pos - cell_origin)

func offset_to_world(offset_pos):
	var map_cell = map_to_world(offset_pos)
	var cell_origin = map_to_world(map_cell)
	return cell_origin + get_cell_transform().xform(offset_pos - map_cell)

func world_to_axial(world_pos):
	return get_axial_transform().affine_inverse().xform(world_pos)

func axial_to_world(axial_pos):
	return get_axial_transform().xform(axial_pos)
