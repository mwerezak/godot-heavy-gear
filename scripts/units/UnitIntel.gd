## represents what a side knows about a unit
## intermediates between units and GUI
extends Reference

const IntelLevel = preload("res://scripts/game/VisionNet.gd").IntelLevel

var unit_id
var intel_level

func _init(unit_id, intel_level = Level.HIDDEN):
	self.unit_id = unit_id
	self.intel_level = intel_level

## all of these may be null to represent missing info
var owner_side
var faction
var name
var unit_model
var unit_type
var cell_position
var draw_position
var position
var facing

func get_object_id():
	return unit_id

func update(unit, new_level = null):
	## optionally update intel level
	if new_level: intel_level = new_level
	
	for data_level in LEVEL_DATA:
		if data_level <= intel_level:
			var properties = LEVEL_DATA[data_level]
			for property in properties:
				var accessor = properties[property]
				set(property, get_script().call(accessor, unit))

## each level implies access to the data of the levels beneath it
const LEVEL_DATA = {
	IntelLevel.UNIDENT: {
		cell_position = "_get_cell_position",
		draw_position = "_get_draw_position",
		position = "_get_position",
		facing = "_get_facing",
		unit_type = "_get_unit_type",
	},
	IntelLevel.OBSERVED: {
		unit_model = "_get_model",
		faction = "_get_faction",
		owner_side = "_get_owner_side",
	},
	IntelLevel.FULL: {
		name = "_get_name",
		## probably more to come
	},
}

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
