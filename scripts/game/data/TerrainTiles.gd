## A "terrain tile" defines a terrain hex's appearance

extends Node

const Constants = preload("res://scripts/Constants.gd")

enum { OFFSET_CENTER, OFFSET_ROOT }

const TILE_TEXTURES = {
	woodland0 = preload("res://icons/terrain/woodland/woodland0.png"),
} 

const SCATTERS = {
	bush = {
		offset_mode = OFFSET_ROOT,
		base_radius = 17,
		zlayer = Constants.DEFAULT_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/bush0.png"),
			preload("res://icons/terrain/woodland/bush1.png"),
		],
	},
	flowers = {
		offset_mode = OFFSET_CENTER,
		base_radius = 8,
		zlayer = Constants.GROUND_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/flowers0.png"),
			preload("res://icons/terrain/woodland/flowers1.png"),
			preload("res://icons/terrain/woodland/flowers2.png"),
			preload("res://icons/terrain/woodland/flowers3.png"),
			preload("res://icons/terrain/woodland/flowers4.png"),
		],
	},
	flower_patch = {
		offset_mode = OFFSET_CENTER,
		base_radius = 21,
		zlayer = Constants.GROUND_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/flower_patch0.png"),
		],
	},
	rocks = {
		offset_mode = OFFSET_ROOT,
		base_radius = 23,
		zlayer = Constants.GROUND_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/rocks0.png"),
			preload("res://icons/terrain/woodland/rocks1.png"),
		],
	},
	pine_tree = {
		offset_mode = OFFSET_ROOT,
		base_radius = 3,
		zlayer = Constants.DEFAULT_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/pine0.png"),
		],
	},
	round_tree = {
		offset_mode = OFFSET_ROOT,
		base_radius = 5,
		zlayer = Constants.DEFAULT_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/tree0.png"),
			preload("res://icons/terrain/woodland/tree1.png"),
			preload("res://icons/terrain/woodland/tree2.png"),
			preload("res://icons/terrain/woodland/tree3.png"),
			preload("res://icons/terrain/woodland/tree4.png"),
			preload("res://icons/terrain/woodland/tree5.png"),
		],
	},
}

const TILES = {
	## open field tiles
	grassland0 = {
		texture = "woodland0", #texture of the underlying hex
		density = 1.0, #scatter density
		scatters = {
			rocks = 1.0,
			bush = 3.0,
			flowers = 2.0,
			flower_patch = 0.5,
		},
	},
	grassland1 = {
		texture = "woodland0",
		density = 1.5,
		scatters = {
			rocks = 0.5,
			bush = 1.5,
			flowers = 1.5,
			flower_patch = 0.25,
		},
	},
	grassland2 = {
		texture = "woodland0",
		density = 2.0,
		scatters = {
			bush = 1.0,
			flowers = 2.25,
		},
	},
	
	## sparse forest tiles
	sparse_forest0 = {
		texture = "woodland0",
		density = 3.0,
		scatters = {
			pine_tree = 8.0,
			round_tree = 3.0,
			bush = 0.5,
		},
	},
	sparse_forest1 = {
		texture = "woodland0",
		density = 3.5,
		scatters = {
			pine_tree = 8.0,
			round_tree = 3.0,
			bush = 0.5,
		},
	},
	
	## dense forest tiles
	dense_forest0 = {
		texture = "woodland0",
		density = 6.0,
		scatters = {
			pine_tree = 28.0,
			round_tree = 3.0,
		},
	},
}

static func get_info(tile_id):
	return TILES[tile_id]

static func get_texture(texture_id):
	return TILE_TEXTURES[texture_id]