## simple generic message type that renders an identical label to all players

extends "BaseMessage.gd"

var properties

func _init(properties):
	self.properties = properties

func render(player):
	return _create_node(Label, properties)