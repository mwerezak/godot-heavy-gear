extends Node

const PlayerUI = preload("res://scripts/gui/PlayerUI.tscn")

var id setget set_id
var display_name
onready var gui = $PlayerUI

func set_id(new_id):
	name = new_id
	id = new_id

func _ready():
	gui.hide()
	GameState.connect("new_game", self, "_setup", [], CONNECT_ONESHOT)

func _setup():
	gui.setup_map_view(GameState.current_game.world_map)

func render_message(node, message_handler = null):
	gui.message_panel.append(node, message_handler)

"""
## Forward icon view updates to gui
## TODO icon_id -> object conversion
func create_icon(icon_id, icon_type):
	gui.icon_view.create_icon(icon_id, icon_type)

func update_icon(icon_id, update_data):
	gui.icon_view.update_icon(icon_id, update_data)

func delete_icon(icon_id):
	gui.icon_view.delete_icon(icon_id)
"""

func update_view(object_intel):
	gui.icon_view.update_icon(object_intel)

## temp
func get_unit_activation_handler():
	return preload("res://scripts/game/player_handlers/UnitActivation.gd").new(self)