extends Container

onready var camera = $Camera
onready var context_panel = $HUDLayer/LowerLeftPanel/VBoxContainer/ContextContainer
onready var message_panel = $HUDLayer/LowerLeftPanel/VBoxContainer/MessagePanel
onready var unit_info_panel = $HUDLayer/UnitInfoPanel
onready var help_dialog = $HUDLayer/QuickHelp

## someday we will use mapviews tht will be part of the player node, instead of a global world map
var map_view = null setget set_map_view

func set_map_view(view):
	map_view = view
	
	## set camera limits
	camera.set_limit_rect(map_view.get_bounding_rect())

var help_dialog_shown = false
var _saved_visibility = {}
func show():
	.show()
	camera.set_current(true)
	for child in _saved_visibility:
		child.visible = _saved_visibility[child]
	
	## show the help dialog the first time we switch to this player
	if !help_dialog_shown:
		help_dialog.popup_centered()
		help_dialog_shown = true

func hide():
	.hide()
	camera.set_current(false)
	for child in $HUDLayer.get_children():
		_saved_visibility[child] = child.visible
		child.hide()

func _unhandled_input(event):
	if event.is_action_pressed("toggle_elevation"):
		get_tree().call_group("elevation_overlays", "toggle_labels")
	
	## capture any input events related to map objects and forward them to the context_panel
	if event is InputEventMouse:
		var world_map = map_view

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