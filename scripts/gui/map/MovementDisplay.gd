## A scene that handles and displays movement for a single unit

extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const MovementModes = preload("res://scripts/game/data/MovementModes.gd")

const TILE_BLUE = 0
const TILE_YELLOW = 1
const TILE_RED = 2

onready var move_marker = $MoveMarker
onready var mode_label = $MoveMarker/ModeLabel
onready var facing_marker = $MoveMarker/AllowedFacing
onready var movement_tiles = $MovementTiles
onready var move_path_display = $MovementPath

onready var world_coords setget set_coordinate_system

func _ready():
	call_deferred("_deferred_ready")
	
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func set_coordinate_system(coords):
	world_coords = coords
	
	## align the movement tiles with the unit grid
	movement_tiles.cell_size = world_coords.unit_grid.cell_spacing
	movement_tiles.position = world_coords.unit_grid.position - movement_tiles.cell_size/2

func show_movement(possible_moves, current_activation):
	var movement_points = current_activation.active_unit.max_movement_points()
	
	clear_move_marker()
	movement_tiles.clear()
	
	for grid_cell in possible_moves:
		var move_path = possible_moves[grid_cell]
		
		var tile_idx
		if false: #TODO hazard tiles
			tile_idx = TILE_RED
		elif movement_points - move_path.moves_used < current_activation.EXTENDED_MOVE:
			tile_idx = TILE_YELLOW
		else:
			tile_idx = TILE_BLUE

		var tile_cell = world_coords.unit_grid.axial_to_offset(grid_cell)
		movement_tiles.set_cellv(tile_cell, tile_idx)

func place_move_marker(possible_moves, move_pos):
	if !possible_moves.has(move_pos):
		return
	
	var move_path = possible_moves[move_pos]
	var move_mode = move_path.move_mode

	move_marker.show()
	move_marker.position = world_coords.unit_grid.axial_to_world(move_pos)
	mode_label.text = move_mode.name
	
	## facing
	facing_marker.clear()
	if !move_mode.free_rotate:
		var turns_remaining = move_mode.turn_rate - move_path.turns_used
		if turns_remaining < HexUtils.DIR_WRAP/2:
			var facing = move_path.last_facing()
			var min_turn = facing - turns_remaining
			var max_turn = facing + turns_remaining
			facing_marker.set_arc(min_turn, max_turn, true)

	## move path
	var path_points = PoolVector2Array()
	for grid_cell in move_path.positions:
		path_points.push_back(world_coords.unit_grid.axial_to_world(grid_cell))
	move_path_display.points = path_points
	move_path_display.show()

func clear_move_marker():
	move_marker.hide()
	move_path_display.hide()