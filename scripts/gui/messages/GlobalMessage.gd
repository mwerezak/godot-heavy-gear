## simple generic message type that renders an identical label to all players

extends Reference

var properties

func _init(properties):
	self.properties = properties

func dispatch():
	Messages.dispatch_message(self)

func render(player):
	var label = Label.new()
	for key in properties:
		label.set(key, properties[key])
	return label