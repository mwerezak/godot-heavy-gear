extends Container

onready var camera = $Camera
onready var context_panel = $GUILayer/LowerLeftPanel/ContextContainer
onready var unit_info_panel = $GUILayer/UnitInfoPanel
onready var help_dialog = $GUILayer/QuickHelp

## someday we will use mapviews tht will be part of the player node, instead of a global world map
var world_map = null

func setup(world_map):
	self.world_map = world_map
	
	## set camera limits
	camera.set_limit_rect(world_map.get_bounding_rect())

var help_dialog_shown = false
func show():
	.show()
	camera.set_current(true)
	
	## show the help dialog the first time we switch to this player
	if !help_dialog_shown:
		help_dialog.popup_centered()
		help_dialog_shown = true

func hide():
	.hide()
	camera.set_current(false)

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