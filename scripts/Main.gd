extends Node

onready var world_map = $WorldMap
onready var game_state = $GameState
onready var player_ui = null

func _ready():
	game_state.setup(world_map)

	if !game_state.players.empty():
		set_active_ui(game_state.players.front().gui) ##stub
		
		yield(player_ui.context_panel.activate("Wait", {
			message_text = "Begin the game when ready.",
			button_text = "Start Game",
		}), "context_return")
		
		game_state.start_game()

## sets the current hotseat player
func set_active_ui(new_ui):
	if new_ui != player_ui:
		if player_ui:
			player_ui.hide()
		player_ui = new_ui
		player_ui.show()

