extends Node

## ugly, but is there anything actually wrong with it?
signal game_start(game_state)
signal begin_turn(game_state)
signal active_player(game_state, player)
signal player_passed(player)
signal unit_activated(player, unit)

enum {
	GameStart, 
	BeginTurn, 
	ActivePlayer,
	PlayerPassed,
	UnitActivated,
}

const EVENT_TYPES = {
	GameStart: "game_start",
	BeginTurn: "begin_turn",
	ActivePlayer: "active_player",
	PlayerPassed: "player_passed",
	UnitActivated: "unit_activated",
}

func fire_event(event_type, event_args):
	var event_signal = EVENT_TYPES[event_type]
	callv("emit_signal", [event_signal] + event_args)

func autoconnect(handler, binds=[], flags=0):
	for signal_data in get_signal_list():
		var automethod = "_%s" % signal_data.name
		if handler.has_method(automethod):
			connect(signal_data.name, handler, automethod, binds, flags)