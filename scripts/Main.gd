extends Node

const MapLoader = preload("res://scripts/MapLoader.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")
const TerrainView = preload("res://scripts/TerrainView.tscn")

export(PackedScene) var map_scene

onready var world_coords = $WorldCoords
onready var game_state = $GameState

var world_map
var terrain_view #terrain view shared by all local players

var active_ui #the PlayerUI of the active hotseat player

func _ready():
	var map_loader = MapLoader.new(world_coords, map_scene)

	world_map = WorldMap.new()
	world_map.set_coordinate_system(world_coords)
	world_map.load_map(map_loader)

	terrain_view = TerrainView.instance()
	add_child(terrain_view)
	
	terrain_view.set_coordinate_system(world_coords)
	terrain_view.load_terrain(map_loader)
	terrain_view.load_elevation(map_loader)

	game_state.setup(world_map)
	Messages.system_message("Game setup complete.")

	if !game_state.players.empty():
		set_active_ui(game_state.players.front().gui) ##stub

		yield(active_ui.context_panel.activate("Dialog", {
			message_text = "Begin the game when ready.",
			button_text = "Start Game",
		}), "context_return")

		Messages.system_message("Starting game...")
		game_state.start_game()

## sets the current hotseat player
func set_active_ui(new_ui):
	if new_ui != active_ui:
		if active_ui:
			active_ui.hide()
		active_ui = new_ui
		active_ui.show()

