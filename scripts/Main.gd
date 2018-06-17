extends Node

const GameState = preload("res://scripts/game/GameState.gd")
const MapLoader = preload("res://scripts/map/MapLoader.gd")
const WorldMap = preload("res://scripts/map/WorldMap.gd")
const IconManager = preload("res://scripts/map/IconManager.gd")
const TerrainView = preload("res://scripts/map/TerrainView.tscn")

export(PackedScene) var map_scene

onready var world_coords = $WorldCoords

var game_state
var world_map
var terrain_view #terrain view shared by all local players

func _ready():
	setup_server()

	## setup local players' UI
	for player in GameSession.all_players():
		if player.has_node("PlayerUI"):
			player.get_node("PlayerUI").setup_map_view(world_map)

func setup_server():
	game_state = GameState.new()
	for player in GameSession.all_players():
		game_state.add_player(player)

	Messages.system("Loading map...")
	var map_loader = MapLoader.new(world_coords, map_scene)

	var icon_manager = IconManager.new()
	## TODO will prob need to access players and game state

	world_map = WorldMap.new()
	world_map.set_coordinate_system(world_coords)
	world_map.set_icon_manager(icon_manager)
	world_map.load_map(map_loader)

	terrain_view = TerrainView.instance()
	add_child(terrain_view)
	
	terrain_view.set_coordinate_system(world_coords)
	terrain_view.load_terrain(map_loader)
	terrain_view.load_elevation(map_loader)

	game_state.setup(world_map)
	Messages.system("Game setup complete.")

	GameSession.all_players().front().make_active()

	"""
	if !game_state.players.empty():
		set_active_ui(game_state.players.front().gui) ##stub

		yield(active_ui.context_panel.activate("Dialog", {
			message_text = "Begin the game when ready.",
			button_text = "Start Game",
		}), "context_return")

		#Messages.system_message("Starting game...")
		game_state.start_game()
	"""
