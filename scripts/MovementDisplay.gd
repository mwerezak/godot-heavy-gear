## A scene that handles and displays movement for a single unit

extends Node

const MovementCalc = preload("res://scripts/Units/MovementCalc.gd")

const TILE_BLUE = 0
const TILE_YELLOW = 1
const TILE_RED = 2

onready var move_marker = $MoveMarker
onready var facing_marker = $MoveMarker/AllowedFacing
onready var movement_tiles = $MovementTiles
onready var move_path = $MovementPath

onready var world_map = get_parent()

func _ready():
	call_deferred("_deferred_ready")

func _deferred_ready():
	## align the movement tiles with the unit grid
	movement_tiles.cell_size = world_map.unit_grid.cell_size

func setup(move_unit):
	var movement_type = move_unit.unit_info.movement.keys()[0]
	var movement = MovementCalc.new(world_map, move_unit, movement_type)
	
	move_marker.hide()
	move_path.hide()
	show_movement(movement)
	
	return movement

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

func place_move_marker(movement, move_pos):
	if !movement.possible_moves.has(move_pos):
		move_marker.hide()
		return
	
	var move_info = movement.possible_moves[move_pos]

	move_marker.show()
	move_marker.position = world_map.get_grid_pos(move_pos)
	
	## facing
	if movement.free_rotate():
		facing_marker.hide_facing_arc()
	else:
		facing_marker.show_facing_arc(move_info.facing, move_info.turn_remaining)

	## move path
	var path_points = PoolVector2Array()
	for grid_cell in move_info.path:
		path_points.push_back(world_map.get_grid_pos(grid_cell))
	move_path.points = path_points
	move_path.show()