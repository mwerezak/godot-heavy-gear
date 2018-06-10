## simple generic message type that renders a message to one player and an optional message to everyone else.

extends "BaseMessage.gd"

var player
var player_message
var other_message

func _init(player, player_message, other_message = null):
	self.player = player
	self.player_message = player_message
	self.other_message = other_message

func dispatch():
	Messages.dispatch_message(self)

func render(player):
	if player == self.player:
		return _create_node(Label, player_message)
	if other_message:
		return _create_node(Label, other_message)
	return null
