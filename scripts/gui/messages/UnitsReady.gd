
extends "CameraViewMessage.gd"

const Colors = preload("res://scripts/Colors.gd")

var player
var units

func _init(player, units):
	self.player = player
	self.units = units

	link_properties = {
		text = "%d %s ready to be activated." % [ units.size(), "units are" if units.size() > 1 else "unit is" ],
		underline = LinkButton.UNDERLINE_MODE_ON_HOVER,
		modulate = Colors.GAME_MESSAGE,
	}
	label_properties = {
		text = "%s is activating units..." % player.display_name,
		modulate = Colors.SYSTEM_MESSAGE,
	}

func _get_view_for_player(player):
	if player != self.player: return null

	if !player.has_method("get_camera"): return null

	var camera = player.get_camera()

	return {
		camera = camera,
		view = camera.get_objects_view(units),
	}
