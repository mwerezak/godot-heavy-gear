## A scene that handles and displays movement for a single unit

extends Node

const TILE_BLUE = 0
const TILE_YELLOW = 1
const TILE_RED = 2

onready var move_marker = $MoveMarker
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
		
		var cell
		if move_info.hazard:
			cell = TILE_RED
		elif move_info.move_count > 1:
			cell = TILE_YELLOW
		else:
			cell = TILE_BLUE
		movement_tiles.set_cellv(move_cell, cell)

