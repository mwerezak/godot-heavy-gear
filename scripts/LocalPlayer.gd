extends Node

const PlayerUI = preload("res://scripts/gui/PlayerUI.tscn")

var id setget set_id

var display_name
var faction_id

## normally the player color should be taken from the player's faction, but these can be used to override that
var primary_color = null
var secondary_color = null

onready var gui = $PlayerUI

func set_id(new_id):
	name = new_id
	id = name

func _ready():
	gui.hide()

func make_active():
	gui.show()

## Forward icon view updates to gui
func create_icon(icon_id, icon_type):
	gui.icon_view.create_icon(icon_id, icon_type)

func update_icon(icon_id, update_data):
	gui.icon_view.update_icon(icon_id, update_data)

func delete_icon(icon_id):
	pass

func render_message(node, handler = null):
	gui.message_panel.append(node, handler)

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