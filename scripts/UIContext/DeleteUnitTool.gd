extends "UIContextBase.gd"

const SelectableUnit = preload("res://scripts/SelectableUnit.tscn")

func objects_input(map, objects, event):
	if event.is_action_pressed("click_select"):
		objects.front().queue_free()