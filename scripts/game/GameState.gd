extends Node

var players
var active_player
var current_turn

## self-signals for yield
signal _active_player_passed

func _ready():
	EventDispatch.autoconnect(self)

func start_game():
	## setup players
	players = get_children()
	
	EventDispatch.fire_event(EventDispatch.GameStart, [self])
	
	var turn_counter = 0
	while turn_counter == 0:
		turn_counter += 1
		current_turn = {
			turn_count = turn_counter,
			turn_order = players.duplicate(),
		}
		
		EventDispatch.fire_event(EventDispatch.BeginTurn, [self])
		
		for player in current_turn.turn_order:
			active_player = player
			EventDispatch.fire_event(EventDispatch.ActivePlayer, [self, active_player])
			active_player.activate_player()
			
			var passed = null
			while passed != active_player:
				passed = yield(EventDispatch, "player_passed")
