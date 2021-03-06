extends Node

const GameTurn = preload("GameTurn.gd")

signal game_setup
signal game_started

var world_map
var players
var current_turn
var turn_history

func _ready():
	players = []
	for child in get_children():
		players.push_back(child)

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

func get_active_player():
	if current_turn:
		return current_turn.active_player

static func get_instance(scene_tree):
	return scene_tree.get_current_scene().get_node("GameState")