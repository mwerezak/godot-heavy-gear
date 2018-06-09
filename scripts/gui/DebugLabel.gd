extends Label

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

onready var gui = $"../.."
onready var player = gui.get_parent()

func _unhandled_input(event):
	call_deferred("_update_text")

func _update_text():
	var camera = gui.camera
	var world_map = gui.world_map
	var game_state = player.game_state
	
	var mouse_pos = world_map.get_global_mouse_position()
	var terrain_cell = world_map.terrain_grid.get_axial_cell(mouse_pos)
	
	var terrain = world_map.raw_terrain_info(terrain_cell)
	var terrain_id = terrain.terrain_id if terrain else "None"

	var grid_cell = world_map.unit_grid.get_axial_cell(mouse_pos)
	var el_info = world_map.elevation.get_info(grid_cell)
	var elevation_str = "elevation:%s grade:%s " % [ el_info.level, el_info.grade ] if el_info else "N/A"
	
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
	
	text = "%s cell:%s %s terrain:%s x%.2f" % [turn_str, grid_cell, elevation_str, terrain_id, 1/zoom]