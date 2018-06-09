extends Node

onready var camera = $Camera
onready var world_map = $WorldMap
onready var game_state = $GameState
onready var player_ui = null

func _ready():
	game_state.setup(world_map)

#	yield(context_panel.activate("Wait", {
#		message_text = "Begin the game when ready.",
#		button_text = "Start Game",
#	}), "context_return")

	game_state.start_game()

