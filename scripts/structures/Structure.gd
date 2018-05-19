extends Sprite

const Constants = preload("res://scripts/Constants.gd")

var _info

var world_map
var cell_position

func _ready():
	z_as_relative = false
	z_index = Constants.STRUCTURE_ZLAYER

func set_structure_info(info):
	_info = info
	
	## info.offset specifies the LL corner, but sprites are placed at the UL corner
	texture = info.texture
	offset = Vector2(0, -texture.get_size().y)
	centered = false

func set_position(pos):
	position = pos + _info.position_offset

func get_footprint():
	var rects = []
	for relative_rect in _info.footprint:
		var rect = Rect2(relative_rect.position + cell_position, relative_rect.size)
		rects.push_back(rect)
	return rects

func get_structure_id(): return _info.structure_id
func exclude_scatters(): return _info.exclude_scatters
func get_terrain_info(): return _info.terrain_info