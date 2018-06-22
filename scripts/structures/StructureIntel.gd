extends "res://scripts/game/ObjectIntel.gd"

## structure intel is very simple. If the level is above HIDDEN everything is known.
#const ObjectIntel = preload("res://scripts/game/ObjectIntel.gd")

var STRUCTURE_DATA = {
	LEVEL_UNIDENT: {
		structure_type = "_get_structure_type",
		cell_position = "_get_cell_position",
		draw_position = "_get_draw_position",
		position = "_get_position",
	},
}

func _init(object_id, object_type, intel_level = Level.HIDDEN).(object_id, object_type, intel_level):
	pass

func _get_data_map():
	return STRUCTURE_DATA

static func _get_structure_type(struct):
	return struct.get_structure_type()
static func _get_cell_position(struct):
	return struct.cell_position
static func _get_draw_position(struct):
	return struct.world_map.unit_grid.axial_to_world(struct.cell_position)
static func _get_position(struct):
	return struct.get_true_position()
