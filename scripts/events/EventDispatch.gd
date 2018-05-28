extends Node

var game_events = preload("res://scripts/events/GameEvents.gd").new()

func game_event(event_signal, event_args):
	game_events.callv("emit_signal", [event_signal] + event_args)