extends Reference

const UnitActivation = preload("res://scripts/units/UnitActivation.gd")

signal end_turn

var turn_num
var game_state 
var initiative_order

var active_player
var unit_activations = {}

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
		active_player.activation_turn(self)

		var passed = null
		while passed != player:
			passed = yield(game_state, "player_passed")

	emit_signal("end_turn")

func activate_unit(unit):
	if !unit_activations.has(unit):
		unit_activations[unit] = UnitActivation.new(unit)
	return unit_activations[unit]