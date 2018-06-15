extends Node

const PlayerUI = preload("res://scripts/gui/PlayerUI.tscn")

var display_name
var faction_id

## normally the player color should be taken from the player's faction, but these can be used to override that
var primary_color = null
var secondary_color = null

onready var gui = $PlayerUI setget , get_gui

func _ready():
	name = display_name
	gui.hide()

func make_active():
	gui.show()

func get_gui():
	return gui

"""
func render_message(message):
	gui.message_panel.append(message, message.render(self))

func activation_turn(current_turn, available_units):
	get_tree().get_current_scene().set_active_ui(gui)

	Messages.UnitsReady.new(self, available_units).dispatch()

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