extends Sprite

const Constants = preload("res://scripts/Constants.gd")

export(String) var structure_id

var structure_info setget set_structure_info
var cell_position setget set_cell_position

onready var world_map = get_parent()

func _ready():
	z_as_relative = false
	z_index = Constants.STRUCTURE_ZLAYER
	call_deferred("_ready_deferred")

func _ready_deferred():
	if world_map:
		## snap to grid
		var cell_pos = world_map.get_grid_cell(position)
		set_cell_position(cell_pos)
	
	var structure_info = StructureDefs.get_info(structure_id)
	set_structure_info(structure_info)

func set_structure_info(info):
	structure_info = info
	
	## info.offset specifies the LL corner, but sprites are placed at the UL corner
	texture = info.texture
	offset = info.offset + Vector2(0, -texture.get_size().y)
	centered = false

func set_cell_position(cell_pos):
	cell_position = cell_pos
	if world_map:
		position = world_map.get_grid_pos(cell_pos)