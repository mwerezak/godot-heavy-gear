extends Node

const Colors = preload("res://scripts/Colors.gd")

var player

var current_turn
var active_unit
var ready_units

func _init(player, current_turn, ready_units):
	self.player = player
	self.current_turn = current_turn
	self.ready_units = ready_units

func next_active_unit():
	var pos_arr = []
	for unit in ready_units:
		var unit_icon = player.gui.icon_view.get_icon(unit)
		if unit_icon:
			pos_arr.push_back(unit_icon.global_position)

	var message_text = "%d %s ready to be activated." % [ ready_units.size(), "units are" if ready_units.size() > 1 else "unit is" ]
	Messages.dispatch_player(
		player, 
		Messages.message_view_pos(pos_arr, message_text, Colors.GAME_MESSAGE),
		Messages.message_label("%s is activating units..." % player.display_name, Colors.PASSIVE_MESSAGE)
	)

	var select_unit = player.gui.context_panel.activate("SelectUnit", {
		select_from = ready_units,
		select_text = "Select a unit to activate.",
		confirm_text = "Select a unit to activate (or double-click to confirm).",
		button_text = "Activate",
	})
	var selection_group = yield(select_unit, "context_return")
	return selection_group.get_selected()

func do_unit_activation(unit):
	active_unit = unit


"""
func activation_turn(current_turn, available_units):
	get_tree().get_current_scene().set_active_ui(gui)

	var unit_pos = []
	for unit in available_units:
		unit_pos.push_back(unit.global_position)

	var message_text = "%d %s ready to be activated." % [ available_units.size(), "units are" if available_units.size() > 1 else "unit is" ]
	Messages.dispatch_player(
		self, 
		Messages.message_view_pos(unit_pos, message_text, Colors.GAME_MESSAGE),
		Messages.message_label("%s is activating units..." % player.display_name, Colors.PASSIVE_MESSAGE),
	)

	var select_unit = gui.context_panel.activate("SelectUnit", {
		select_from = available_units,
		select_text = "Select a unit to activate.",
		confirm_text = "Select a unit to activate (or double-click to confirm).",
		button_text = "Activate",
	})
	var selection_group = yield(select_unit, "context_return")
	var selected = selection_group.get_selected()
	
	assert(selected.size() == 1)
	assert(available_units.has(selected.front()))
	
	var unit = selected.front()
	var current_activation = current_turn.activate_unit(unit)
	
	yield(gui.context_panel.activate("UnitActions", { current_activation = current_activation }), "context_return")
	
	selection_group.clear()
	
	emit_signal("pass_turn")
"""