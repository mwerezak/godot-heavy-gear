## the backend for the multiplayer lobby
## contains all player nodes, and manages their connection and disconnection

extends Node

const LocalPlayer = preload("res://scripts/LocalPlayer.tscn")

func _ready():
	## for now, just create a couple of local players for testing
	_debug_create_player("0", "Player 1")
	_debug_create_player("1", "Player 2")

func _debug_create_player(id, name):
	var player = LocalPlayer.instance()
	player.id = id
	player.display_name = name
	add_child(player)
	print(player.name)

func get_player(player_id):
	return get_node(player_id)

func all_players():
	return get_children()