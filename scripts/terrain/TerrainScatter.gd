extends Sprite

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const TerrainTiles = preload("res://scripts/game/data/TerrainTiles.gd")

var base_radius = 0
var offset_mode = TerrainTiles.OFFSET_CENTER setget set_offset_mode

func _init(scatter_info = null):
	if scatter_info: setup(scatter_info)

func setup(scatter_info):
	base_radius = scatter_info.base_radius
	texture = RandomUtils.get_random_item(scatter_info.textures)
	z_as_relative = false
	z_index = scatter_info.zlayer
	set_offset_mode(scatter_info.offset_mode)

func set_offset_mode(mode):
	offset_mode = mode
	match offset_mode:
		TerrainTiles.OFFSET_CENTER:
			offset = Vector2()
		TerrainTiles.OFFSET_ROOT:
			offset = Vector2(0, -texture.get_size().y/2)

