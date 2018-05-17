extends Node

const MovementModes = preload("res://scripts/game/MovementModes.gd")

## TODO terrain elevation?

const DEFAULT_DIFFICULT_TERRAIN = {  
	MovementModes.GROUND: 2.0,
}

const TILESET_WOODLAND = preload("res://tilesets/TerrainTiles.tres")

const TILESETS = {
	TILESET_WOODLAND : {
		terrain_types = {
			grassland = {
				name = "Grassland", #display name
				tileset_id = "default",
				tile_ids = ["Grass0", "Grass1", "Grass2", "Grass3", "Grass4", "Grass5", "Grass6"],
				height = 0, #height of the terrain above elevation - e.g. for forests, how tall are the trees?
				difficult = {}, #limits movement on this terrain for certain movement types
				dangerous = {}, #moving through this terrain using certain movement types may cause damage and immobilize the unit
				impassable = {}, #cannot be entered using these movement types
			},
			sparse_forest = {
				name = "Sparse Forest",
				tileset_id = "default",
				tile_ids = ["SparseForest0", "SparseForest1", "SparseForest2", "SparseForest3", "SparseForest4"],
				height = 1.67,
				difficult = {},
				dangerous = {},
				impassable = {}, #cannot be entered using these movement types
			},
			dense_forest = {
				name = "Dense Forest",
				tileset_id = "default",
				tile_ids = ["DenseForest0", "DenseForest1", "DenseForest2"],
				height = 2.5, #taller trees than sparse forest
				difficult = DEFAULT_DIFFICULT_TERRAIN,
				dangerous = {},
				impassable = {}, #cannot be entered using these movement types
			},
		}
	}
}

func _init():
	for tileset in TILESETS:
		var tileset_info = TILESETS[tileset]
		
		tileset_info.terrain_ids = {} ## reverse mapping of tile_id -> terrain_id
		
		var terrain_types = tileset_info.terrain_types
		for terrain_id in terrain_types:
			var terrain_info = terrain_types[terrain_id]
			terrain_info.terrain_id = terrain_id
			
			for tile_id in terrain_info.tile_ids:
				tileset_info.terrain_ids[tile_id] = terrain_id

func get_terrain_info(tileset, tile_idx):
	if tile_idx < 0: return null
	
	var tile_id = tileset.tile_get_name(tile_idx)
	var tileset_info = TILESETS[tileset]
	var terrain_id = tileset_info.terrain_ids[tile_id]
	return tileset_info.terrain_types[terrain_id]

