extends "ContextBase.gd"

const Unit = preload("res://scripts/Units/Unit.tscn")

onready var unit_type_button = $HBoxContainer/UnitTypeButton

var unit_models = {}

func _ready():
	var selection_id = 0
	for model_id in UnitTypes.INFO:
		unit_models[selection_id] = model_id
		
		var info = UnitTypes.get_info(model_id)
		unit_type_button.add_item(info.get_name(), selection_id)
		
		selection_id += 1

func unit_cell_input(world_map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		var spawn_unit = Unit.instance()
		
		var selection_id = unit_type_button.get_selected_id()
		var model_id = unit_models[selection_id]
		spawn_unit.set_unit_type(model_id)
		
		if world_map.unit_can_place(spawn_unit, cell_pos):
			world_map.add_object(spawn_unit, cell_pos)
			spawn_unit.facing = randi()
		else:
			spawn_unit.queue_free()