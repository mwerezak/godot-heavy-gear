extends Node

onready var context_panel = $GUILayer/LowerLeftPanel/ContextContainer
onready var unit_info_panel = $GUILayer/UnitInfoPanel
onready var camera = $Camera
onready var world_map = $WorldMap

onready var game_state = $GameState

func _ready():
	## seed
	randomize()
	
	## set camera limits
	camera.set_limit_rect(world_map.get_bounding_rect())
	
	## register Context Panel items
	context_panel.register("dev_spawn_unit", context_panel.get_node("SpawnUnit"))
	context_panel.register("dev_delete_unit", context_panel.get_node("DeleteUnit"))
	context_panel.register("activate_unit", context_panel.get_node("ActivateUnit"))
	context_panel.register("unit_actions", context_panel.get_node("UnitActions"))
	context_panel.register("move_unit", context_panel.get_node("MoveUnit"))
	context_panel.register("select_facing", context_panel.get_node("SelectFacing"))
	
	var help_dialog = $GUILayer/QuickHelp
	help_dialog.popup_centered()
	
	game_state.start_game(self)


func _unhandled_input(event):
	if event.is_action_pressed("toggle_elevation"):
		get_tree().call_group("elevation_overlays", "toggle_labels")
	
	## capture any input events related to map objects and forward them to the context_panel
	if event is InputEventMouse:
		## grid cell position events
		var mouse_pos = world_map.get_global_mouse_position()
		if world_map.point_on_map(mouse_pos):
			var grid_cell = world_map.unit_grid.get_axial_cell(mouse_pos)
			context_panel.cell_input_event(world_map, grid_cell, event)
			_update_unit_info_panel(world_map.get_units_at_cell(grid_cell), event)

func _update_unit_info_panel(units, event):
	if event.is_action_pressed("click_select"):
		unit_info_panel.select_units(units)
	elif event is InputEventMouseMotion:
		unit_info_panel.hover_units(units)