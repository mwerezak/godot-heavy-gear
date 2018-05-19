extends Node

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

## enumerate movement type IDs
const WALKER = "walker"
const GROUND = "ground"
const INFANTRY = "infantry"


## TODO split to another file
const MOVEMENT_TYPES = {
	WALKER : {
		name = "Walker",   #display name
		road_bonus = 1.0,  #bonus movement when on roads
		turn_rate = null,  #the max direction steps the unit can turn in a single move action, or null for unlimited (see Direction.gd)
	},
	GROUND : {
		name = "Ground",
		road_bonus = 2.0,
		turn_rate = HexUtils.TURN_90DEG,
	},
	INFANTRY : {
		name = "Foot",
		road_bonus = 1.0,
		turn_rate = null,
	},
	## TODO hover and flying movement types - probably need to sort out terrain elevation first
}

static func get_move_type(move_type_id):
	return MOVEMENT_TYPES[move_type_id]

## creating new movement modes from a move_spec (see UnitTypes.gd) and a movement type
static func create(move_spec, move_type_id):
	var mode_info = get_move_type(move_type_id)
	return {
		type_id = move_type_id,
		name = mode_info.name,
		speed = move_spec.speed,
		turn_rate = mode_info.turn_rate,
		free_rotate = (mode_info.turn_rate == null),
		road_bonus = mode_info.road_bonus,
		reversed = false,
	}

static func create_reversed(move_spec, move_type_id):
	var mode_info = get_move_type(move_type_id)
	return {
		type_id = move_type_id,
		name = "%s (Reversed)" % mode_info.name,
		speed = move_spec.reverse,
		turn_rate = mode_info.turn_rate,
		free_rotate = (mode_info.turn_rate == null),
		road_bonus = mode_info.road_bonus,
		reversed = true,
	}

## lexical sort used to determine what movement mode to use by default for rotations
static func default_rotation_lexical(movement_mode):
	return [
		1 if !movement_mode.reversed else -1, #prefer forward movement, not that it matters much since fwd and rev movement modes share the same ID
		1 if movement_mode.free_rotate else -1, #prefer free rotations
		movement_mode.speed, #otherwise prefer faster movement modes (since we'll be stuck with it once we rotate)
		movement_mode.turn_rate,
		hash(movement_mode),
	]

