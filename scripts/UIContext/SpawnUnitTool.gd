extends "UIContextBase.gd"

const SelectableUnit = preload("res://scripts/SelectableUnit.tscn")

func position_input(map, position, event):
	if event.is_action_pressed("click_select"):
		var spawn_unit = SelectableUnit.instance()
		spawn_unit.position = position
		map.world.add_child(spawn_unit)