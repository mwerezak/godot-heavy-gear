extends "ContextBase.gd"

func cell_input(world_map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		var units = world_map.get_units_at_cell(cell_pos)
		var unit = units.front()
		if unit:
			world_map.remove_unit(unit)
			unit.queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		context_manager.deactivate()

func _done_button_pressed():
	context_manager.deactivate()
