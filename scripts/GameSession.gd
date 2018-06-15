## the backend for the multiplayer lobby
## contains all player nodes, and manages their connection and disconnection

extends Node

const LocalPlayer = preload("res://scripts/LocalPlayer.tscn")

func _ready():
	## for now, just create a couple of local players for testing
	_debug_create_player("Player 1", "north")
	_debug_create_player("Player 2", "south")

func _debug_create_player(name, faction):
	var player = LocalPlayer.instance()
	player.display_name = name
	player.faction_id = faction
	add_child(player)

func all_players():
	return get_children()