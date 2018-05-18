extends Sprite

const Constants = preload("res://scripts/Constants.gd")

export(String) var structure_id

var structure_info setget set_structure_info

var world_map
var cell_position

func _ready():
	z_as_relative = false
	z_index = Constants.STRUCTURE_ZLAYER
	
	var structure_info = StructureDefs.get_info(structure_id)
	set_structure_info(structure_info)

func set_structure_info(info):
	structure_info = info
	
	## info.offset specifies the LL corner, but sprites are placed at the UL corner
	texture = info.texture
	offset = Vector2(0, -texture.get_size().y)
	centered = false

func set_position(pos):
	position = pos + structure_info.position_offset

func get_footprint():
	var rects = []
	for relative_rect in structure_info.footprint:
		var rect = Rect2(relative_rect.position + cell_position, relative_rect.size)
		rects.push_back(rect)
	return rects

func exclude_scatters():
	return structure_info.exclude_scatters
