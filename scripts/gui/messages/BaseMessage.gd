## TODO filter category, once that is implemented

extends Reference

func dispatch():
	Messages.dispatch_message(self)

## return a Control to be added to the message log panel, or null to render nothing
func render(player):
	return null

## helper function to create a node of a certain type with set properties
static func _create_node(node_type, properties):
	var node = node_type.new()
	for key in properties:
		node.set(key, properties[key])
	return node