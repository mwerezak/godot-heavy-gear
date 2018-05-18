extends Node

const Constants = preload("res://scripts/Constants.gd")

enum { OFFSET_CENTER, OFFSET_ROOT }

const SCATTERS = {
	bush = {
		offset = OFFSET_ROOT,
		base_radius = 17,
		zlayer = Constants.DEFAULT_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/bush0.png"),
			preload("res://icons/terrain/woodland/bush1.png"),
		],
	},
	flowers = {
		offset = OFFSET_CENTER,
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
		offset = OFFSET_CENTER,
		base_radius = 21,
		zlayer = Constants.GROUND_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/flower_patch0.png"),
		],
	},
	rocks = {
		offset = OFFSET_ROOT,
		base_radius = 23,
		zlayer = Constants.GROUND_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/rocks0.png"),
			preload("res://icons/terrain/woodland/rocks1.png"),
		],
	},
	pine_tree = {
		offset = OFFSET_ROOT,
		base_radius = 5,
		zlayer = Constants.DEFAULT_SCATTER_ZLAYER,
		textures = [
			preload("res://icons/terrain/woodland/pine0.png"),
		],
	},
	round_tree = {
		offset = OFFSET_ROOT,
		base_radius = 8,
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

const OVERLAYS = {
	grassland = {
		scatters = [
			{
				randweight = 1.0,
				density = 1.0,
				scatters = {
					rocks = 1.0,
					bush = 3.0,
					flowers = 2.0,
					flower_patch = 0.5,
				},
			},
			{
				randweight = 1.0,
				density = 1.5,
				scatters = {
					rocks = 0.5,
					bush = 1.5,
					flowers = 1.5,
					flower_patch = 0.25,
				},
			},
			{
				randweight = 0.8,
				density = 2.0,
				scatters = {
					bush = 1.0,
					flowers = 2.25,
				},
			},
		],
	},
	sparse_forest = {
		scatters = [
			{
				randweight = 1.0,
				density = 3.5,
				scatters = {
					pine_tree = 8.0,
					round_tree = 3.0,
					bush = 0.5,
				},
			},
			{
				randweight = 1.0,
				density = 4.0,
				scatters = {
					pine_tree = 8.0,
					round_tree = 3.0,
					bush = 0.5,
				},
			},
		],
	},
	dense_forest = {
		scatters = [
			{
				randweight = 1.0,
				density = 6.0,
				scatters = {
					pine_tree = 28.0,
					round_tree = 3.0,
				},
			},
		],
	}
}