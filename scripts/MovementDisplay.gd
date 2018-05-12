## A scene that handles and displays movement for a single unit

extends Node

const TILE_BLUE = 0
const TILE_YELLOW = 1
const TILE_RED = 2

onready var movement_tiles = $MovementTiles

onready var world_map = get_parent()

func _ready():
	call_deferred("_deferred_ready")

func _deferred_ready():
	## align the movement tiles with the unit grid
	movement_tiles.cell_size = world_map.unit_grid.cell_size

func show_movement(movement):
	movement_tiles.clear()
	
	for move_cell in movement.possible_moves:
		var move_info = movement.possible_moves[move_cell]
		if move_info.move_count <= 1:
			movement_tiles.set_cellv(move_cell, TILE_BLUE)
		else:
			movement_tiles.set_cellv(move_cell, TILE_YELLOW)
	

## Produces an AStar reference that can be used to path the given unit
## this is a rather complex problem that needs to take into account not
## only valid locations the unit can move and movement costs but also 
## the unit's current facing and its ability to turn.
#func generate_pathing(move_unit):
#	var pathing = AStar.new()
#
#func setup_movement(move_unit, pathing, destination):
#	pass
#
#func finalize_movement():
#	pass