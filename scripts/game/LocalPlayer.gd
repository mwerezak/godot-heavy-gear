extends "Player.gd"

onready var gui = $PlayerUI

func _ready():
	._ready()
	game_state.connect("game_setup", self, "_setup")
	gui.hide()

func _setup():
	gui.map_view = game_state.world_map

func render_message(message):
	gui.message_panel.append(message, message.render(self))

func activation_turn(current_turn, available_units):
	get_tree().get_current_scene().set_active_ui(gui)

	Messages.dispatch("UnitsReady", [self, available_units])

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