extends Node

const TerrainTiles = preload("TerrainTiles.gd")
const MovementModes = preload("MovementModes.gd")

## TODO terrain elevation?

const DEFAULT_DIFFICULT_TERRAIN = {  
	MovementModes.GROUND: 2.0,
}

## allows lookup of terrain_id using the tileset tile name
var tileset
var TERRAIN_LOOKUP = {}

const INFO = {
	grassland = {
		name = "Grassland", #display name
		tiles = {
			grassland0 = 1.0,
			grassland1 = 1.0,
			grassland2 = 0.8,
		},
		height = 0, #height of the terrain above elevation - e.g. for forests, how tall are the trees? This defines the cover volume.
		difficult = {}, #limits movement on this terrain for certain movement types
		dangerous = [], #moving through this terrain using certain movement types may cause damage and immobilize the unit
		impassable = [], #cannot be entered using these movement types
	},
	sparse_forest = {
		name = "Sparse Forest",
		tiles = {
			sparse_forest0 = 1.0,
			sparse_forest1 = 1.0,
		},
		height = 1.67,
		difficult = {},
		dangerous = [],
		impassable = [], #cannot be entered using these movement types
	},
	dense_forest = {
		name = "Dense Forest",
		tiles = {
			dense_forest0 = 1.0,
		},
		height = 2.5, #taller trees than sparse forest
		difficult = DEFAULT_DIFFICULT_TERRAIN,
		dangerous = [],
		impassable = [], #cannot be entered using these movement types
	},
}

func _init():
	## create the terrain tileset
	tileset = TileSet.new()
	
	for terrain_id in INFO:
		var terrain_info = INFO[terrain_id]
		
		terrain_info.terrain_id = terrain_id
		terrain_info.lookup_ids = {}
		for tile_id in terrain_info.tiles:
			var tile_info = TerrainTiles.get_info(tile_id)
			var lookup_id = "%s_%s" % [terrain_id, tile_id] #unique ID for lookup
			terrain_info.lookup_ids[tile_id] = lookup_id
			TERRAIN_LOOKUP[lookup_id] = terrain_id
			
			## create the tileset entry
			var texture = TerrainTiles.get_texture(tile_info.texture)
			var offset = Vector2(0, -texture.get_size().y/8)
			
			var idx = tileset.get_last_unused_tile_id()
			tileset.create_tile(idx)
			tileset.tile_set_name(idx, lookup_id)
			tileset.tile_set_texture(idx, texture)
			tileset.tile_set_texture_offset(idx, offset)

func get_terrain_info(tile_id):
	if !TERRAIN_LOOKUP.has(tile_id):
		return null
	
	var terrain_id = TERRAIN_LOOKUP[tile_id]
	return INFO[terrain_id]
