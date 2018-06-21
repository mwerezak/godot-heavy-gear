extends Reference

#const UnitActivation = preload("res://scripts/units/UnitActivation.gd")

class InitiativeGroup:
	var turn
	var player
	var units

	func _init(current_turn, player, units):
		self.turn = current_turn
		self.player = player
		self.units = units.duplicate()

	func get_ready_units():
		var rval = []
		for unit in units:
			## TODO, count unfinished activations as well
			if !turn.unit_activations.has(unit):
				rval.push_back(unit)
		return rval

	func count_ready_units():
		var count = 0
		for unit in units:
			## TODO, count unfinished activations as well
			if !turn.unit_activations.has(unit):
				count += 1
		return count

## GameTurn

var turn_num
var game_state 
var init_queue = []

var active_player
var unit_activations = {}

func _init(game_state, turn_num):
	self.game_state = game_state
	self.turn_num = turn_num

func roll_initiative():
	## create initiative groups and determine initiative order
	init_queue.clear()
	for side in game_state.side.values():
		var init_group = InitiativeGroup.new(self, side.player, side.owned_units)
		if init_group.count_ready_units() > 0:
			init_queue.push_back(init_group)

func do_turn():
	Messages.global("* It is now Turn %d." % turn_num)
	roll_initiative()

	## Activation Phase
	
	while !init_queue.empty():
		## consider the next group at the front of the queue
		var next_group = init_queue.pop_front()

		## for each group in the queue, activate once, then continue activating as long as 
		## that group has >= twice the number of ready units as all other groups
		var other_ready = 0
		for other_group in init_queue:
			other_ready += other_group.count_ready_units()

		var i = 0
		while i == 0 || next_group.count_ready_units() >= 2*other_ready:
			i += 1
			yield(activate_group(next_group), "complete")

		## replace the group back at the end of the queue as long as it has ready units left
		if next_group.count_ready_units() > 0:
			init_queue.push_back(next_group)

func activate_group(init_group):
	var ready_units = init_group.get_ready_units()
	var handler = init_group.player.get_unit_activation_handler()
	var next_unit = yield(handler.next_active_unit(ready_units), "complete")



"""
func can_activate(unit):
	return !unit_activations.has(unit) ## stub

func activate_unit(unit):
	if !unit_activations.has(unit):
		unit_activations[unit] = UnitActivation.new(unit)
	return unit_activations[unit]
"""

