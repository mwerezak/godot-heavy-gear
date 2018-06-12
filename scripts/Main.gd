extends Node

const MapLoader = preload("res://scripts/MapLoader.gd")

export(PackedScene) var map_scene

onready var world_coords = $WorldCoords
onready var world_map = $WorldMap
onready var game_state = $GameState
onready var player_ui = null

func _ready():
	var map_loader = MapLoader.new(world_coords, map_scene)

	world_map.set_coordinate_system(world_coords)
	world_map.load_map(map_loader)

	game_state.setup(world_map)
	Messages.system_message("Game setup complete.")

	if !game_state.players.empty():
		set_active_ui(game_state.players.front().gui) ##stub

		yield(player_ui.context_panel.activate("Dialog", {
			message_text = "Begin the game when ready.",
			button_text = "Start Game",
		}), "context_return")

		Messages.system_message("Starting game...")
		game_state.start_game()

## sets the current hotseat player
func set_active_ui(new_ui):
	if new_ui != player_ui:
		if player_ui:
			player_ui.hide()
		player_ui = new_ui
		player_ui.show()

