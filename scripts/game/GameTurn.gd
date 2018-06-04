extends Reference

signal end_turn

var turn_num
var game_state 
var initiative_order

var active_player

func _init(game_state, turn_num):
	self.game_state = game_state
	self.turn_num = turn_num

func roll_initiative():
	return game_state.players.duplicate() ## stub

func begin_turn():
	initiative_order = roll_initiative()
	do_turn()

func do_turn():
	for player in initiative_order:
		active_player = player
		active_player.activated()

		var passed = null
		while passed != player:
			passed = yield(game_state, "player_passed")

	emit_signal("end_turn")