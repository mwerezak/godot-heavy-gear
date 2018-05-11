## A scene that handles and displays movement for a single unit

extends Node

onready var world = $".."

## produces an AStar reference that can be used to path the given unit
## this is a rather complex problem that needs to take into account not
## only valid locations the unit can move and movement costs but also 
## the unit's current facing and its ability to turn.
func generate_pathing(move_unit):
	var pathing = AStar.new()

func setup_movement(move_unit, pathing, destination):
	pass

func finalize_movement():
	pass