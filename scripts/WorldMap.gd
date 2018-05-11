extends Node2D

const TERRAIN_CELL_SIZE = Vector2(256, 220)
const UNIT_CELL_SIZE = TERRAIN_CELL_SIZE/4

onready var terrain = $TerrainTiles
onready var unit_grid = $UnitGrid

func _ready():
	terrain.cell_size = TERRAIN_CELL_SIZE
	unit_grid.cell_size = UNIT_CELL_SIZE

## returns the bounding rectangle in world coords
func get_bounding_rect():
	var cell_bounds = terrain.get_used_rect()
	var cell_size = terrain.cell_size
	var cell_to_pixel = Transform2D(Vector2(cell_size.x, 0), Vector2(0, cell_size.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)

func get_terrain_at(world_pos):
	var cell_pos = terrain.world_to_map(world_pos)
	return get_terrain_at_cell(cell_pos)

func get_terrain_at_cell(cell_pos):
	var tile_id = terrain.get_cellv(cell_pos)
	return TerrainTypes.get_tile_terrain_info(tile_id)

func point_on_map(world_pos):
	var cell_pos = terrain.world_to_map(world_pos)
	var tile_id = terrain.get_cellv(cell_pos)
	return tile_id >= 0

func add_object(object):
	assert point_on_map(object.position)
	
	#snap to grid
	var cell_pos = terrain.world_to_map(object.position)
	object.position = terrain.map_to_world(cell_pos)
	
	add_child(object)