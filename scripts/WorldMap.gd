extends Node2D

const TERRAIN_ZLAYER = -1

onready var terrain = $TerrainTiles

func _ready():
	terrain.z_index = TERRAIN_ZLAYER

func get_bounding_rect():
	var cell_bounds = terrain.get_used_rect()
	var cell_size = terrain.cell_size
	var cell_to_pixel = Transform2D(Vector2(cell_size.x, 0), Vector2(0, cell_size.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)