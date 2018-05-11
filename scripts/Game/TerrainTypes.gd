extends Node

const MovementTypes = preload("res://scripts/Game/MovementTypes.gd")

## TODO terrain elevation?

## maps tile ID to terrain ID, populated by _init()
var TILE_IDS = {}

const DEFAULT_DIFFICULT_TERRAIN = {  
	MovementTypes.TYPE_GROUND: 2.0,
}

const INFO = {
	grassland = {
		tile_ids = [0, 3, 4, 5, 6, 7, 8],
		name = "Grassland", #display name
		height = 0, #height of the terrain above elevation - e.g. for forests, how tall are the trees?
		difficult = {}, #limits movement on this terrain for certain movement types
		dangerous = {}, #moving through this terrain using certain movement types may cause damage and immobilize the unit
	},
	sparse_forest = {
		tile_ids = [1, 9, 10, 11, 12],
		name = "Sparse Forest",
		height = 1.67,
		difficult = {},
		dangerous = {},
	},
	dense_forest = {
		tile_ids = [2, 13, 14],
		name = "Dense Forest",
		height = 2.5, #taller trees than sparse forest
		difficult = DEFAULT_DIFFICULT_TERRAIN,
		dangerous = {},
	},
}

func _init():
	for terrain_id in INFO:
		var terrain_info = INFO[terrain_id]
		terrain_info.terrain_id = terrain_id
		
		for tile_id in terrain_info.tile_ids:
			TILE_IDS[tile_id] = terrain_id

func has_tile_id(tile_id):
	return TILE_IDS.has(tile_id)

func get_tile_terrain_info(tile_id):
	if !has_tile_id(tile_id): return null
	
	var terrain_id = TILE_IDS[tile_id]
	return INFO[terrain_id]

