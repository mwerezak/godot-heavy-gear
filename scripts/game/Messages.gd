extends Node

const GameState = preload("res://scripts/game/GameState.gd")

## message types registry
const TYPES = {
	Global = preload("res://scripts/gui/messages/GlobalMessage.gd"),
	Player = preload("res://scripts/gui/messages/PlayerMessage.gd"),
	UnitsReady = preload("res://scripts/gui/messages/UnitsReady.gd"),
}

## core send message function
## sends a message object to all players that can render messages
func dispatch_message(message):
	var game_state = GameState.get_instance(get_tree())
	if !game_state: return
	
	for player in game_state.players:
		if player.has_method("render_message"):
			player.render_message(message)

## helper function for dynamic message types

func dispatch(message_type, args):
	var message = TYPES[message_type].callv("new", args)
	dispatch_message(message)

## helper functions for common message types
const Colors = preload("res://scripts/Colors.gd")

func system_message(message_text):
	var message = TYPES.Global.new({
		text = message_text,
		modulate = Colors.SYSTEM_MESSAGE
	})
	dispatch_message(message)

func global_message(message_text):
	var message = TYPES.Global.new({
		text = "* " + message_text,
		modulate = Colors.GLOBAL_MESSAGE
	})
	dispatch_message(message)

func player_message(player, message_text, other_text = null):
	var message = TYPES.Player.new(
		player,
		{
			text = message_text,
			modulate = Colors.GAME_MESSAGE,
		},
		{
			text = other_text,
			modulate = Colors.GAME_MESSAGE,
		} if other_text else null
	)
	dispatch_message(message)