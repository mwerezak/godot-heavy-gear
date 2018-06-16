extends Sprite

const Constants = preload("res://scripts/Constants.gd")

func _ready():
	centered = false
	z_as_relative = false
	z_index = Constants.STRUCTURE_ZLAYER
	connect("texture_changed", self, "_texture_changed")

func _texture_changed():
	## structure sprites are anchored at the LL corner instead of the UL
	offset = Vector2(0, -texture.get_size().y)

## whitelist of properties that can be updated remotely
const UPDATE_PROPERTIES = [
	"texture",
	"position",
]
func update(data):
	for key in UPDATE_PROPERTIES:
		if data.has(key):
			set(key, data[key])
