extends Node

const GameState = preload("res://scripts/game/GameState.gd")
const PlayerActivation = preload("res://scripts/game/PlayerActivation.gd")
const PlayerUI = preload("res://scripts/gui/PlayerUI.tscn")

var id setget set_id
var display_name
onready var gui = $PlayerUI

func set_id(new_id):
	name = new_id
	id = new_id

func _ready():
	gui.hide()

## Forward icon view updates to gui
## TODO icon_id -> object conversion
func create_icon(icon_id, icon_type):
	gui.icon_view.create_icon(icon_id, icon_type)

func update_icon(icon_id, update_data):
	gui.icon_view.update_icon(icon_id, update_data)

func delete_icon(icon_id):
	gui.icon_view.delete_icon(icon_id)

func render_message(node, handler = null):
	gui.message_panel.append(node, handler)

func activation_turn(ready_units):
	var game_state = GameState.get_instance(get_tree())
	var activation = PlayerActivation.new(self, game_state.current_turn, ready_units)
	gui.show()

	var active_unit = activation.next_active_unit()
