## Container for all state related to a unit's activation
## e.g. action points/moves remaining etc.

extends Reference

var active_unit

var action_points
var move_actions
var movement_mode

## for partial move actions
var partial_moves = 0
var partial_turns = 0

## how far the unit has moved this activation
## a proxy for how fast the unit is moving
## determines modifiers to hit and defend
var distance_moved = 0

func _init(unit):
	var unit_info = unit.unit_info
	active_unit = unit
	action_points = unit_info.max_action_points()
	move_actions = unit_info.max_move_actions()

func move_unit(move_pos, move_info):
	active_unit.cell_position = move_pos
	
	move_actions -= move_info.move_count
	partial_moves = move_info.moves_remaining
	partial_turns = move_info.turns_remaining if move_info.turns_remaining else 0
	
	movement_mode = move_info.movement_mode
	distance_moved += active_unit.world_map.path_distance(move_info.path)