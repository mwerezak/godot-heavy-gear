## the world coordinate system

extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

## dimensions of terrain hexes
## it is important that these are all multiples of 16, due to the geometry of hex grids
## and the fact that the unit grid must fit exactly into the terrain grid
## note that for regular hexagons, w = sqrt(3)/2 * h
const TERRAIN_WIDTH  = 16*16 #256
const TERRAIN_HEIGHT = 18*16 #288

const UNITGRID_WIDTH = TERRAIN_WIDTH/4 #64
const UNITGRID_HEIGHT = TERRAIN_HEIGHT/4 #72

onready var terrain_grid = $TerrainGrid
onready var unit_grid = $UnitGrid

func _ready():
	terrain_grid.cell_size = Vector2(TERRAIN_WIDTH, TERRAIN_HEIGHT)
	unit_grid.cell_size = Vector2(UNITGRID_WIDTH, UNITGRID_HEIGHT)

## obtains the terrain cell that contains this grid cell
func get_terrain_cell(grid_cell):
	var world_pos = unit_grid.axial_to_world(grid_cell)
	return terrain_grid.get_axial_cell(world_pos)
