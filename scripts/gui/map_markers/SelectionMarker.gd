extends Sprite

const Constants = preload("res://scripts/Constants.gd")

enum {
	STATE_MARKED,
	STATE_HOVER,
	STATE_SELECTED,
	STATE_DISABLED,
}

const DEFAULT_COLOR = Color(0.7, 0.7, 0.7, 0.8)
const SELECTED_COLOR = Color(0.35, 1.0, 0.35, 1.0)

var selection_state = STATE_DISABLED setget set_state

onready var host = get_parent()
onready var label = $Transparent/LocLabel

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

	label.text = host.get_display_label() if host.has_method("get_display_label") else ""

func set_state(state):
	if state != selection_state:
		selection_state = state

		visible = (state != STATE_DISABLED)
		label.visible = (state != STATE_MARKED)
		modulate = SELECTED_COLOR if state == STATE_SELECTED else DEFAULT_COLOR
