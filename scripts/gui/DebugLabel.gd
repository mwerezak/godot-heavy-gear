extends Label

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

onready var gui = $"../.."
onready var player = gui.get_parent()

func _unhandled_input(event):
	call_deferred("_update_text")

func _update_text():
	var camera = gui.camera
	var world_map = gui.map_view
	var world_coords = world_map.world_coords
	var game_state = player.game_state
	
	var mouse_pos = gui.map_view.get_global_mouse_position()
	var terrain_cell = world_coords.terrain_grid.get_axial_cell(mouse_pos)
	
	var terrain = world_map.raw_terrain_info(terrain_cell)
	var terrain_id = terrain.terrain_id if terrain else "None"

	var axial_pos = world_coords.unit_grid.world_to_axial(mouse_pos)
	var grid_cell = world_coords.unit_grid.get_axial_cell(mouse_pos)
	var el_info = world_map.elevation.get_info(grid_cell)
	var elevation_str = "z:%s " % el_info.level
	
	var structure = world_map.get_structure_at_cell(grid_cell)
	if structure:
		terrain_id += ":" + structure.get_structure_id()

	var turn_str = "Not Started"
	if game_state.current_turn:
		var active_player = game_state.current_turn.active_player
		turn_str = "Turn %d %s" % [
			game_state.current_turn.turn_num if game_state.current_turn else "Not Started",
			active_player.display_name if active_player else "",
		]
	
	var zoom = camera.zoom.x
	
	text = "%s mouse:%s %s cell:%s terrain:%s %s" % [turn_str, mouse_pos, axial_pos, grid_cell, terrain_id, elevation_str]