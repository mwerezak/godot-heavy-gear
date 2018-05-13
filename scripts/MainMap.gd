extends Node

onready var context_panel = $HUDLayer/LowerLeftPanel/ContextPanel
onready var camera = $Camera
onready var world = $WorldMap

onready var move_marker = $MoveMarker

var ui_contexts = {
	dev_spawn_unit = preload("res://scripts/GUI/ContextPanel/SpawnUnitTool.tscn"),
	dev_delete_unit = preload("res://scripts/GUI/ContextPanel/DeleteUnitTool.tscn"),
	activate_unit = preload("res://scripts/GUI/ContextPanel/ActivateUnit.tscn"),
	move_unit = preload("res://scripts/GUI/ContextPanel/MoveUnit.tscn"),
}

func _ready():
	## set camera limits
	var map_rect = world.get_bounding_rect()
	camera.set_limit_rect(map_rect)
	
	## load and register UI Contexts
	for context_name in ui_contexts:
		var instance = ui_contexts[context_name].instance()
		context_panel.register(instance, context_name)
	
	## load the initial context
	context_panel.activate("activate_unit")

## capture any input events related to map objects and forward them to the context_panel
func _unhandled_input(event):
	if event is InputEventMouse:
		## unit cell position events
		var mouse_pos = world.get_global_mouse_position()
		if world.point_on_map(mouse_pos):
			var cell_pos = world.get_grid_cell(mouse_pos)
			context_panel.unit_cell_input_event(self, cell_pos, event)
		
		## terrain hex events
		var hex_pos = world.get_terrain_hex(mouse_pos)
		var terrain = world.get_terrain_at_hex(hex_pos)
		if terrain:
			context_panel.terrain_input_event(self, hex_pos, terrain, event)
		
		## map marker events
		var map_markers = []
		for marker_obj in get_tree().get_nodes_in_group("map_markers"):
			if marker_obj.has_mouse:
				map_markers.push_back(marker_obj)
		if !map_markers.empty():
			context_panel.map_markers_input_event(self, map_markers, event)