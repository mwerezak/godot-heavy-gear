extends "ContextBase.gd"

const Unit = preload("res://scripts/Units/Unit.tscn")

func unit_cell_input(world_map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		var spawn_unit = Unit.instance()
		if world_map.unit_can_place(spawn_unit, cell_pos):
			world_map.add_object(spawn_unit, cell_pos)
			spawn_unit.facing = randi()
		else:
			spawn_unit.queue_free()