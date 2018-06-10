extends Node

const GameState = preload("res://scripts/game/GameState.gd")

func _all_players():
	var game_state = GameState.get_instance(get_tree())
	return game_state.players if game_state else []

## core send message function
## sends a message object to all players that can render messages
func dispatch_message(message):
	for player in _all_players():
		if player.has_method("render_message"):
			player.render_message(message)


## helper functions for common message types
const Colors = preload("res://scripts/Colors.gd")
const GlobalMessage = preload("res://scripts/gui/messages/GlobalMessage.gd")

func system_message(message_text):
	var message = GlobalMessage.new({
		text = message_text,
		modulate = Colors.SYSTEM_MESSAGE
	})
	dispatch_message(message)