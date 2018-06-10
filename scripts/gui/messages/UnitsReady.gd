## simple generic message type that renders a message to one player and an optional message to everyone else.

extends Reference

const Colors = preload("res://scripts/Colors.gd")

var player
var units
var units_view = {}

func _init(player, units):
	self.player = player
	self.units = units

func render(player):
	if player != self.player: return null
	
	var gui = player.get("gui")
	if !gui: return null

	var button = LinkButton.new()
	button.text = "%d units are ready to be activated." % units.size()
	button.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
	button.modulate = Colors.GAME_MESSAGE
	button.connect("pressed", self, "_link_button_pressed", [player])

	## store a view of the units, since they may move around or disappear in later turns
	units_view[player] = gui.camera.get_objects_view(units)

	return button

func _link_button_pressed(player):
	var camera = player.gui.camera
	camera.set_view_smooth(units_view[player])