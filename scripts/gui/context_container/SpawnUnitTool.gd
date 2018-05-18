extends "ContextBase.gd"

const Unit = preload("res://scripts/units/Unit.tscn")
const Crew = preload("res://scripts/units/Crew.gd")

onready var unit_model_button = $HBoxContainer/UnitModelButton
onready var faction_button = $HBoxContainer/FactionButton

var factions = {}
var unit_models = {}

func _ready():
	var i = 0
	for faction_id in Factions.all_factions():
		var faction = Factions.get_info(faction_id)
		faction_button.add_item(faction.name, i)
		factions[i] = faction
		
		var j = 0
		var models = {}
		for model_id in faction.unit_models:
			models[j] = UnitModels.get_info(model_id)
			j += 1
		
		unit_models[i] = models
		i += 1
	
	_update_model_list(faction_button.get_selected_id())

func _faction_button_item_selected(i):
	_update_model_list(i)

func _update_model_list(i):
	unit_model_button.clear()
	for j in unit_models[i]:
		var unit_info = unit_models[i][j]
		unit_model_button.add_item(unit_info.desc.name, j)

func unit_cell_input(world_map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		var spawn_unit = Unit.instance()
		
		var i = faction_button.get_selected_id()
		var j = unit_model_button.get_selected_id()
		var faction = factions[i]
		var unit_info = unit_models[i][j]

		spawn_unit.set_faction(faction)
		spawn_unit.set_unit_info(unit_info)
		
		if world_map.unit_can_place(spawn_unit, cell_pos):
			var crew = Crew.new(faction, unit_info.get_default_crew())
			spawn_unit.set_crew_info(crew)
			
			spawn_unit.cell_position = cell_pos
			world_map.add_unit(spawn_unit)
			
			if spawn_unit.has_facing():
				context_manager.activate("select_facing", { unit = spawn_unit, forced = true })
			
		else:
			spawn_unit.queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		context_manager.deactivate()

func _done_button_pressed():
	context_manager.deactivate()
