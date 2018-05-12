extends Node

const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")

## default base sizes
const BASE_SIZE_GEAR = 1.0
const BASE_SIZE_GEAR_LARGE = 1.5
const BASE_SIZE_INFANTRY = 1.5
const BASE_SIZE_VEHICLE = 1.5
const BASE_SIZE_VEHICLE_LARGE = 3.0
const BASE_SIZE_STRIDER = 1.5

const INFO = {
	dummy = {
		name = "Dummy Unit",
		
		base_size = 1.0,
		height = 0.5,
		
		use_facing = true, #if units should track their facing and direction
		movement = {
			MovementTypes.TYPE_WALKER: 5.0,
		},
	}
}

