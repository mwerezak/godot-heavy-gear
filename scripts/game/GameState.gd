extends Node

signal new_game

var current_game

func create_new_game(world_map):
	current_game = GameState.new(world_map)
	emit_signal("new_game")

func get_current_game():
	return current_game


## Game State

const GameTurn = preload("GameTurn.gd")
const ForceSide = preload("ForceSide.gd")

class GameState:
	var world_map
	var sides = {} #map player nodes -> side
	var current_turn
	var turn_history

	func _init(world_map):
		self.world_map = world_map
		current_turn = null
		turn_history = []

	func create_side(new_player, side_info):
		sides[new_player] = ForceSide.new(self, new_player, side_info)

	func get_player_side(player):
		return sides[player]

	func has_player(player):
		return sides.has(player)

	func run_game():
		while true:
			current_turn = GameTurn.new(self, turn_history.size() + 1)
			yield(current_turn.do_turn(), "complete")
			turn_history.push_back(current_turn)

	func get_active_player():
		if current_turn:
			return current_turn.active_player

	static func get_current_game(scene_tree):
		return scene_tree.get_current_scene().game_state