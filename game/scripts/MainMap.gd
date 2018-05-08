extends Node

onready var ui_context = $HUDLayer/LowerLeftPanel/UIContextPanel
onready var camera = $Camera
onready var world = $WorldMap

var ui_contexts = {
	dev_spawn_unit = preload("res://scripts/UIContext/SpawnUnitTool.tscn"),
	dev_delete_unit = preload("res://scripts/UIContext/DeleteUnitTool.tscn"),
}

func _ready():
	## load and register UI Contexts
	for context_name in ui_contexts:
		var instance = ui_contexts[context_name].instance()
		instance.name = context_name
		ui_context.register(instance)

## capture any input events related to map objects and forward them to the ui_context
func _unhandled_input(event):
	if event is InputEventMouse:
		var mouse_pos = world.get_global_mouse_position()
		ui_context.position_input_event(self, mouse_pos, event)
		
		## TODO - terrain events
		
		var selected = []
		for selectable in get_tree().get_nodes_in_group("mouse_selectable"):
			if selectable.has_mouse:
				selected.push_back(selectable)
		if not selected.empty():
			ui_context.objects_input_event(self, selected, event)