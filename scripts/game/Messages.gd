extends Node

const Colors = preload("res://scripts/Colors.gd")

const RENDER_METHODS = [
	"_render_label",
	"_render_mapview",
]

## funcs to recieve messages on the client machine (client-side)
func _receive_message(player_id, message_data):
	if RENDER_METHODS.has(message_data.render_func):
		var player = GameSession.get_player(player_id)
		callv(message_data.render_func, [ player ] + message_data.render_args)

func _render_label(player, label_data):
	var label = Label.new()
	label.text = label_data.text
	label.modulate = label_data.color

	player.render_message(label)

func _render_mapview(player, label_data, view_rect):
	var link_button = LinkButton.new()
	link_button.text = label_data.text
	link_button.modulate = label_data.color
	link_button.underline = LinkButton.UNDERLINE_MODE_ON_HOVER

	var handler = MapViewMessageHandler.new()
	handler.local_player = player
	handler.view_rect = view_rect
	link_button.connect("pressed", handler, "focus_view")

	player.render_message(link_button, handler)

class MapViewMessageHandler:
	var local_player
	var view_rect
	func focus_view():
		local_player.gui.camera.set_view_smooth(view_rect)

## message dispatch funcs (server-side)

func dispatch_global(message_data):
	for player in GameSession.all_players():
		_receive_message(player.id, message_data)

func dispatch_player(target_player, message_data, other_data = null):
	for player in GameSession.all_players():
		if player == target_player:
			_receive_message(player.id, message_data)
		elif other_data:
			_receive_message(player.id, other_data)

## message data helpers

func message_label(message_text, message_color):
	return {
		render_func = "_render_label",
		render_args = [{
			text = message_text,
			color = message_color,
		}],
	}

func message_view_rect(view_rect, message_text, message_color):
	return {
		render_func = "_render_mapview",
		render_args = [
			{
				text = message_text,
				color = message_color,
			},
			view_rect,
		],
	}

func message_view_pos(pos_array, message_text, message_color):
	if pos_array.empty():
		return message_label(message_text, message_color)

	var view_rect = Rect2(pos_array.front(), Vector2())
	for pos in pos_array:
		view_rect = view_rect.expand(pos)
	
	var margin = max(50, 0.2*max(view_rect.size.x, view_rect.size.y))
	view_rect = view_rect.grow(margin)

	return message_view_rect(view_rect, message_text, message_color)


## message presets

func generic(message_text, message_color):
	dispatch_global(message_label(message_text, message_color))

func system(message_text):
	dispatch_global(message_label(message_text, Colors.SYSTEM_MESSAGE))

func global(message_text):
	dispatch_global(message_label(message_text, Colors.GLOBAL_MESSAGE))

func player(player, message_text, other_text = null):
	var player_message = message_label(message_text, Colors.GAME_MESSAGE)
	var other_message = message_label(other_text, Colors.GAME_MESSAGE) if other_text else null
	dispatch_player(player, player_message, other_message)

