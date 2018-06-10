extends Reference

const UnitActivation = preload("res://scripts/units/UnitActivation.gd")

signal end_turn

var turn_num
var game_state 
var initiative_queue

var active_player
var unit_activations = {}

func _init(game_state, turn_num):
	self.game_state = game_state
	self.turn_num = turn_num

func roll_initiative():
	initiative_queue = []
	for player in game_state.players:
		## TODO command groups
		if !player.owned_units.empty():
			var initiative_group = {
				player = player,
				units = player.owned_units.duplicate(),
			}
			initiative_queue.push_back(initiative_group)


func begin_turn():
	Messages.global_message("It is now Turn %d." % turn_num)
	roll_initiative()
	do_turn()

func do_turn():
	## set number of activations for each group
	for init_group in initiative_queue:
		init_group.activations = init_group.units.size()

	while !initiative_queue.empty():
		var next_group = initiative_queue.pop_front()

		## count the number of activations of all other initiative groups
		var other_activations = 0
		for other_group in initiative_queue:
			other_activations += other_group.activations

		var i = 0
		active_player = next_group.player
		while next_group.activations > 0 && (i == 0 || next_group.activations >= 2*other_activations):
			i += 1

			var activate_units = []
			for unit in next_group.units:
				if can_activate(unit):
					activate_units.push_back(unit)

			if activate_units.empty():
				next_group.activations = 0
				break

			active_player.activation_turn(self, activate_units)
			yield(active_player, "pass_turn")
			next_group.activations -= 1

		active_player = null
		if next_group.activations > 0:
			initiative_queue.push_back(next_group)

	emit_signal("end_turn")


func can_activate(unit):
	return !unit_activations.has(unit) ## stub

func activate_unit(unit):
	if !unit_activations.has(unit):
		unit_activations[unit] = UnitActivation.new(unit)
	return unit_activations[unit]