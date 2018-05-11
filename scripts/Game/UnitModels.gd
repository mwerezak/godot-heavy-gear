extends Node

const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")

const UNIT_INFO = {
	dummy = {
		name = "Dummy Unit",
		movement = {
			MovementTypes.TYPE_WALKER: 5.0,
		}
	}
}