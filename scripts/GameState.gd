extends Node

const GameEvents = preload("res://scripts/events/GameEvents.gd")

var players
var current_turn

## self-signals for yield
signal _next_activation

func start_game():
	## setup players
	players = get_children()
	
	EventDispatch.game_event("game_start", [self])
	
	var turn_counter = 0
	while turn_counter == 0:
		turn_counter += 1
		current_turn = {
			turn_count = turn_counter,
			turn_order = players.duplicate(),
		}
	
		EventDispatch.game_event("begin_turn", [self])
		
		for player in current_turn.turn_order:
			pass

