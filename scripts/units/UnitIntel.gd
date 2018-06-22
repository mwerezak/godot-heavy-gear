extends "res://scripts/game/ObjectIntel.gd"

var UNIT_DATA = {
	LEVEL_UNIDENT: {
		cell_position = "_get_cell_position",
		draw_position = "_get_draw_position",
		position = "_get_position",
		facing = "_get_facing",
		unit_type = "_get_unit_type",
	},
	LEVEL_OBSERVED: {
		unit_model = "_get_model",
		faction = "_get_faction",
		owner_side = "_get_owner_side",
	},
	LEVEL_FULL: {
		name = "_get_name",
		## probably more to come
	},
}

func _init(object_id, object_type, intel_level = Level.HIDDEN).(object_id, object_type, intel_level):
	pass

func _get_data_map():
	return UNIT_DATA

## unit data accessor functions
static func _get_cell_position(unit):
	return unit.cell_position
static func _get_draw_position(unit):
	return unit.world_map.unit_grid.axial_to_world(unit.cell_position)
static func _get_position(unit):
	return unit.get_true_position()
static func _get_facing(unit):
	return unit.facing
static func _get_unit_type(unit):
	return unit.unit_model.unit_type()
static func _get_model(unit):
	return unit.unit_model.get_model_id()
static func _get_faction(unit):
	return unit.faction.faction_id
static func _get_owner_side(unit):
	return unit.owner_side
static func _get_name(unit):
	return unit.get_display_label()
