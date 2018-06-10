## simple generic message type that renders a message to one player and an optional message to everyone else.

extends Reference

var player
var player_message
var other_message

func _init(player, player_message, other_message = null):
	self.player = player
	self.player_message = player_message
	self.other_message = other_message

func render(player):
	if player == self.player:
		return _create_label(player_message)
	if other_message:
		return _create_label(other_message)
	return null

static func _create_label(properties):
	var label = Label.new()
	for key in properties:
		label.set(key, properties[key])
	return label