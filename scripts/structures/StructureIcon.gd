extends Sprite

const Constants = preload("res://scripts/Constants.gd")

## Need to apply an offset to the structure sprite as specified by the structure type
## however this offset needs to be applied to position (not texture offset) in order
## for Y-sorting to work correctly
var _position_offset = Vector2()

func _ready():
	centered = false
	z_as_relative = false
	z_index = Constants.STRUCTURE_ZLAYER
	connect("texture_changed", self, "_update_offset")

## structure sprites are anchored at the LL corner instead of the UL
func _update_offset():
	offset = Vector2(0, -texture.get_size().y)

func update(data):
	if data.has("structure_type"):
		var struct_info = GameData.get_structure_info(data.structure_type)
		_position_offset = struct_info.position_offset
		set_texture(struct_info.texture)

	if data.has("draw_position"):
		position = data.draw_position + _position_offset

