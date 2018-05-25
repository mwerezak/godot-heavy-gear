## A scene that handles and displays movement for a single unit

extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const MovementModes = preload("res://scripts/game/MovementModes.gd")

const TILE_BLUE = 0
const TILE_YELLOW = 1
const TILE_RED = 2

onready var move_marker = $MoveMarker
onready var mode_label = $MoveMarker/ModeLabel
onready var facing_marker = $MoveMarker/AllowedFacing
onready var movement_tiles = $MovementTiles
onready var move_path = $MovementPath

onready var world_map = get_parent()

func _ready():
	call_deferred("_deferred_ready")
	
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _deferred_ready():
	## align the movement tiles with the unit grid
	movement_tiles.cell_size = world_map.unit_grid.cell_spacing
	movement_tiles.position = world_map.unit_grid.position - movement_tiles.cell_size/2

func show_movement(possible_moves, current_activation):
	var move_actions = current_activation.move_actions
	
	clear_move_marker()
	movement_tiles.clear()
	
	for grid_cell in possible_moves:
		var move_info = possible_moves[grid_cell]
		
		var tile_idx
		if move_info.hazard:
			tile_idx = TILE_RED
		elif move_actions - move_info.move_count < current_activation.EXTENDED_MOVE:
			tile_idx = TILE_YELLOW
		else:
			tile_idx = TILE_BLUE

		var tile_cell = world_map.unit_grid.axial_to_offset(grid_cell)
		movement_tiles.set_cellv(tile_cell, tile_idx)

func place_move_marker(possible_moves, move_pos):
	if !possible_moves.has(move_pos):
		return
	
	var move_info = possible_moves[move_pos]
	var movement_mode = move_info.movement_mode

	move_marker.show()
	move_marker.position = world_map.unit_grid.axial_to_world(move_pos)
	mode_label.text = movement_mode.name
	
	## facing
	facing_marker.clear()
	if !move_info.movement_mode.free_rotate && move_info.turns_remaining < HexUtils.DIR_WRAP/2:
		var min_turn = move_info.facing - move_info.turns_remaining
		var max_turn = move_info.facing + move_info.turns_remaining
		facing_marker.set_arc(min_turn, max_turn, true)

	## move path
	var path_points = PoolVector2Array()
	for grid_cell in move_info.path:
		path_points.push_back(world_map.unit_grid.axial_to_world(grid_cell))
	move_path.points = path_points
	move_path.show()

func clear_move_marker():
	move_marker.hide()
	move_path.hide()