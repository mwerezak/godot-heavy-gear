const Colors = preload("res://scripts/Colors.gd")

var player

func _init(player):
	self.player = player

func next_active_unit(ready_units):
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

