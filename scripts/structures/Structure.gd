extends Node

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var _info

var world_map
var cell_position setget set_cell_position
var footprint setget , get_footprint

func set_structure_info(info):
	_info = info

func get_structure_id(): return _info.structure_id
func exclude_scatters(): return _info.exclude_scatters
func get_terrain_info(): return _info.terrain_info

func set_cell_position(new_pos):
	cell_position = new_pos
	footprint = null

## returns the grid cells on the map occupied by this structure
func get_footprint():
	if !footprint:
		var offset_anchor = world_map.unit_grid.axial_to_offset(cell_position)

		var footprint_cells = {} #ensure all items in footprint are unique
		for rect in _info.footprint:
			var shifted_rect = Rect2(rect.position + offset_anchor, rect.size)
			for offset_cell in HexUtils.get_rect(shifted_rect):
				var grid_cell = world_map.unit_grid.offset_to_axial(offset_cell)
				footprint_cells[grid_cell] = true
		footprint = footprint_cells.keys()
	return footprint

func create_sprite():
	var sprite = Sprite.new()

	sprite.z_as_relative = false
	sprite.z_index = Constants.STRUCTURE_ZLAYER

	## info.offset specifies the LL corner, but sprites are placed at the UL corner
	sprite.texture = _info.texture
	sprite.offset = Vector2(0, -_info.texture.get_size().y) + _info.position_offset
	sprite.centered = false

	sprite.position = world_map.unit_grid.axial_to_world(cell_position)
	return sprite