## helper base class for message types that may optionally focus on a part of the map when clicked

extends "BaseMessage.gd"

var link_properties = {}
var label_properties = null # optionally show a label to those who cannot view anything

var saved_views = {}

func _get_view_for_player(player):
	return null

func render(player):
	var view_info = _get_view_for_player(player)
	if view_info:
		saved_views[player] = view_info

		var button = _create_node(LinkButton, link_properties)

		button.connect("pressed", self, "_link_button_pressed", [player])
		return button

	if label_properties:
		return _create_node(Label, label_properties)

	return null

func _link_button_pressed(player):
	var view_info = saved_views[player]
	view_info.camera.set_view_smooth(view_info.view)
