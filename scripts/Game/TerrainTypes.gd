extends Node

## maps tile ID to terrain ID, populated by _init()
var TILE_IDS = {}

var TERRAIN_INFO = {
	grassland = {
		tile_id = 1,
		name = "Grassland",
		height = 0, #height of the terrain above elevation - e.g. forests
		difficult = false,
	},
	sparse_forest = {
		tile_id = 2,
		name = "Sparse Forest",
		height = 2,
		difficult = false,
	},
	dense_forest = {
		tile_id = 3,
		name = "Dense Forest",
		height = 2,
		difficult = true,
	},
}

func _init():
	for terrain_id in TERRAIN_INFO:
		var terrain_info = TERRAIN_INFO[terrain_id]
		terrain_info.terrain_id = terrain_id
		TILE_IDS[terrain_info.tile_id] = terrain_id

func get_tile_terrain_info(tile_id):
	if !TILE_IDS.has(tile_id): return null
	
	var terrain_id = TILE_IDS[tile_id]
	return TERRAIN_INFO[terrain_id]
