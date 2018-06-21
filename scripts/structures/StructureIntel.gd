## vastly simplified version of UnitIntel but for structures
extends Reference

const IntelLevel = preload("res://scripts/game/VisionNet.gd").IntelLevel

var struct_id
var intel_level

func _init(struct_id, intel_level = Level.HIDDEN):
	self.struct_id = struct_id
	self.intel_level = intel_level

var structure_type
var cell_position
var draw_position
var position

func get_object_id():
	return struct_id

## structure intel is very simple. If the level is above HIDDEN everything is known.
func update(struct, new_level = null):
	if new_level > IntelLevel.HIDDEN:
		structure_type = struct.get_structure_type()
		cell_position = struct.cell_position
		draw_position = struct.world_map.unit_grid.axial_to_world(cell_position)
		position = struct.get_true_position()
