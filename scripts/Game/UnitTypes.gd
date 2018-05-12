extends Node

const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")

const INFO = {
	dummy = {
		name = "Dummy Unit",
		base_size = 1.8,
		height = 0.5,
		movement = {
			MovementTypes.TYPE_WALKER: 5.0,
		}
	}
}

