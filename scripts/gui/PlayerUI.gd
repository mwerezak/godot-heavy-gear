extends Container

onready var player = get_parent()
onready var camera = $Camera
onready var icon_view = $IconView
onready var terrain_cursor = $TerrainCursor
onready var context_panel = $HUDLayer/LowerLeftPanel/VBoxContainer/ContextContainer
onready var message_panel = $HUDLayer/LowerLeftPanel/VBoxContainer/MessagePanel
onready var unit_info_panel = $HUDLayer/UnitInfoPanel
onready var help_dialog = $HUDLayer/QuickHelp

## Switching the active player for hotseat
var help_dialog_shown = false
var _saved_visibility = {}
func show():
	.show()
	set_process_unhandled_input(true)
	camera.set_current(true)
	for child in _saved_visibility:
		child.visible = _saved_visibility[child]
	
	## show the help dialog the first time we switch to this player
	if !help_dialog_shown:
		help_dialog.popup_centered()
		help_dialog_shown = true

func hide():
	.hide()
	set_process_unhandled_input(false)
	camera.set_current(false)
	for child in $HUDLayer.get_children():
		_saved_visibility[child] = child.visible
		child.hide()

func setup_map_view(world_map):
	camera.set_limit_rect(world_map.display_rect)
	icon_view.create_scatter_icons(world_map.terrain_scatters)
	terrain_cursor.setup(world_map)


## Player input handling

func _unhandled_input(event):
	## capture any input events related to map objects and forward them to the context_panel
	if event is InputEventMouse:
		## grid cell position events
		var mouse_pos = get_global_mouse_position()

		var current_scene = get_tree().get_current_scene()
		var world_map = current_scene.world_map
		if world_map.has_point(mouse_pos):
			var grid_cell = world_map.world_coords.unit_grid.get_axial_cell(mouse_pos)
			context_panel.cell_input_event(world_map, grid_cell, event)
			_update_unit_info_panel(world_map.get_units_at_cell(grid_cell), event)

##TODO move this into info panel
func _update_unit_info_panel(units, event):
	if event.is_action_pressed("click_select"):
		unit_info_panel.select_units(units)
	elif event is InputEventMouseMotion:
		unit_info_panel.hover_units(units)
