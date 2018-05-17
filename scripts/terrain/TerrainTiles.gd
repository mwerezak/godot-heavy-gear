extends Node

enum ScatterOffset { CENTER, ROOT }

const SCATTERS = {
	bush = {
		offset = ScatterOffset.ROOT,
		base_radius = 17,
		z_index = 1,
		textures = [
			preload("res://icons/terrain/woodland/bush0.png"),
			preload("res://icons/terrain/woodland/bush1.png"),
		],
	},
	flowers = {
		offset = ScatterOffset.CENTER,
		base_radius = 8,
		z_index = 0,
		textures = [
			preload("res://icons/terrain/woodland/flowers0.png"),
			preload("res://icons/terrain/woodland/flowers1.png"),
			preload("res://icons/terrain/woodland/flowers2.png"),
			preload("res://icons/terrain/woodland/flowers3.png"),
			preload("res://icons/terrain/woodland/flowers4.png"),
		],
	},
	flower_patch = {
		offset = ScatterOffset.CENTER,
		base_radius = 21,
		z_index = 0,
		textures = [
			preload("res://icons/terrain/woodland/flower_patch0.png"),
		],
	},
	pine_tree = {
		offset = ScatterOffset.ROOT,
		base_radius = 5,
		z_index = 2,
		textures = [
			preload("res://icons/terrain/woodland/pine0.png"),
		],
	},
	round_tree = {
		offset = ScatterOffset.ROOT,
		base_radius = 8,
		z_index = 2,
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
					bush = 3.0,
					flowers = 2.0,
					flower_patch = 0.5,
				},
			},
			{
				randweight = 1.0,
				density = 1.5,
				scatters = {
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
				density = 3.0,
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