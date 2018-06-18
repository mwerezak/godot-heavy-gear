extends Reference

const GameTurn = preload("GameTurn.gd")
const PlayerData = preload("PlayerData.gd")

signal game_setup
signal game_started

var world_map
var players = {} #map player nodes -> player data
var current_turn
var turn_history

func add_player(new_player, seat_info):
	players[new_player] = PlayerData.new(self, new_player, seat_info)

func setup(world_map):
	self.world_map = world_map
	current_turn = null
	turn_history = []
	emit_signal("game_setup")

func start_game():
	emit_signal("game_started")
	run_game()

func run_game():
	while true:
		current_turn = GameTurn.new(self, turn_history.size() + 1)
		current_turn.begin_turn()

		yield(current_turn, "end_turn")
		turn_history.push_back(current_turn)

static func get_instance(scene_tree):
	return scene_tree.get_current_scene().game_state