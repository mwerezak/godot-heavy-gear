extends Node

const GameTurn = preload("GameTurn.gd")
const Player = preload("Player.gd")

signal game_started
signal player_passed(player)

var players
var current_turn
var turn_history

func _ready():
	current_turn = null
	turn_history = []

	players = []
	for child in get_children():
		if child is Player:
			players.push_back(child)

func start_game():
	emit_signal("game_started")
	run_game()

func run_game():
	while true:
		current_turn = GameTurn.new(self, turn_history.size() + 1)
		current_turn.begin_turn()

		yield(current_turn, "end_turn")
		turn_history.push_back(current_turn)

func pass_player(player):
	emit_signal("player_passed", player)

func get_active_player():
	if current_turn:
		return current_turn.active_player
	return null

static func get_instance(scene_tree):
	var current_scene = scene_tree.get_current_scene()
	if current_scene.has_node("GameState"):
		return current_scene.get_node("GameState")
	return null