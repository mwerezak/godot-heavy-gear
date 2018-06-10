## helper base class for message types that may optionally focus on a part of the map when clicked

extends Reference

var link_properties = {}
var label_properties = null # optionally show a label to those who cannot view anything

var saved_views = {}

func dispatch():
	Messages.dispatch_message(self)

func _get_view_for_player(player):
	return null

func render(player):
	var view_info = _get_view_for_player(player)
	if view_info:
		saved_views[player] = view_info

		var button = LinkButton.new()
		for key in link_properties:
			button.set(key, link_properties[key])

		button.connect("pressed", self, "_link_button_pressed", [player])
		return button

	if label_properties:
		var label = Label.new()
		for key in label_properties:
			label.set(key, label_properties[key])
		return label

	return null

func _link_button_pressed(player):
	var view_info = saved_views[player]
	view_info.camera.set_view_smooth(view_info.view)
