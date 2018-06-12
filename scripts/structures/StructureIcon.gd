extends Sprite

const Constants = preload("res://scripts/Constants.gd")

var texture setget set_texture

func _ready():
	sprite.z_as_relative = false
	sprite.z_index = Constants.STRUCTURE_ZLAYER

func set_texture(new_texture):
	## structure sprites are anchored at the LL corner instead of the UL
	texture = new_texture
	offset = Vector2(0, -texture.get_size().y)