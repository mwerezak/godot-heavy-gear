extends Node

const MovementModes = preload("MovementModes.gd")

## TODO terrain elevation?

const DEFAULT_DIFFICULT_TERRAIN = {  
	MovementModes.GROUND: 2.0,
}

var TERRAIN_IDS = {}

const INFO = {
	grassland = {
		name = "Grassland", #display name
		tile_ids = {
			grassland0 = preload("res://icons/terrain/woodland/woodland0.png")
		},
		height = 0, #height of the terrain above elevation - e.g. for forests, how tall are the trees?
		difficult = {}, #limits movement on this terrain for certain movement types
		dangerous = [], #moving through this terrain using certain movement types may cause damage and immobilize the unit
		impassable = [], #cannot be entered using these movement types
	},
	sparse_forest = {
		name = "Sparse Forest",
		tile_ids = {
			sparse_forest0 = preload("res://icons/terrain/woodland/woodland0.png")
		},
		height = 1.67,
		difficult = {},
		dangerous = [],
		impassable = [], #cannot be entered using these movement types
	},
	dense_forest = {
		name = "Dense Forest",
		tile_ids = {
			dense_forest0 = preload("res://icons/terrain/woodland/woodland0.png")
		},
		height = 2.5, #taller trees than sparse forest
		difficult = DEFAULT_DIFFICULT_TERRAIN,
		dangerous = [],
		impassable = [], #cannot be entered using these movement types
	},
}

func _init():
	for terrain_id in INFO:
		var terrain_info = INFO[terrain_id]
		terrain_info.terrain_id = terrain_id
		
		for tile_id in terrain_info.tile_ids:
			TERRAIN_IDS[tile_id] = terrain_id

func get_terrain_info(tile_id):
	if !TERRAIN_IDS.has(tile_id):
		return null
	
	var terrain_id = TERRAIN_IDS[tile_id]
	return INFO[terrain_id]

