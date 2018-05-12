extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/HexUtils.gd")

## dimensions of terrain hexes
## it is important that these are both multiples of 4
const TERRAIN_WIDTH  = 64*4 #256
const TERRAIN_HEIGHT = 74*4 #296

const UNITGRID_WIDTH = 16*4
const UNITGRID_HEIGHT = 18*4

onready var terrain = $TerrainTiles
onready var unit_grid = $UnitGrid

func _ready():
	terrain.cell_size = Vector2(TERRAIN_WIDTH, TERRAIN_HEIGHT*3/4)
	unit_grid.cell_size = Vector2(UNITGRID_WIDTH, UNITGRID_HEIGHT*3/4)
	
	terrain.z_as_relative = false
	terrain.z_index = Constants.TERRAIN_ZLAYER

## returns the bounding rectangle in world coords
func get_bounding_rect():
	var cell_bounds = terrain.get_used_rect()
	var cell_size = terrain.cell_size
	var cell_to_pixel = Transform2D(Vector2(cell_size.x, 0), Vector2(0, cell_size.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)

func get_terrain_hex(world_pos):
	return terrain.world_to_map(world_pos)

## returns the position of the hex centre
func get_terrain_pos(hex_pos):
	var hex_origin = terrain.map_to_world(hex_pos)
	return hex_origin + terrain.cell_size/2

func get_terrain_at(world_pos):
	var hex_pos = get_terrain_hex(world_pos)
	return get_terrain_at_hex(hex_pos)

func get_terrain_at_hex(hex_pos):
	var tile_id = terrain.get_cellv(hex_pos)
	return TerrainTypes.get_tile_terrain_info(tile_id)

func point_on_map(world_pos):
	var cell_pos = terrain.world_to_map(world_pos)
	var tile_id = terrain.get_cellv(cell_pos)
	return tile_id >= 0

func get_grid_cell(world_pos):
	var cell_pos = unit_grid.world_to_map(world_pos)
	return cell_pos

## returns the position of the cell centre
func get_grid_pos(cell_pos):
	return unit_grid.map_to_world(cell_pos) + unit_grid.cell_size/2

func add_object(object, cell_pos):
	add_child(object)
	object.cell_position = cell_pos

## gets the closest direction to get from one cell to another
func get_nearest_dir(cell_from, cell_to):
	var from_pos = get_grid_pos(cell_from)
	var to_pos = get_grid_pos(cell_to)
	var total_displacement = to_pos - from_pos
	return HexUtils.nearest_dir(total_displacement.angle())

## returns the distance betwen the centres of two cells, in distance units
func grid_distance(cell1, cell2):
	var pos1 = get_grid_pos(cell1)
	var pos2 = get_grid_pos(cell2)
	var pixel_dist = (pos1 - pos2).length()
	return HexUtils.pixels2units(pixel_dist)
