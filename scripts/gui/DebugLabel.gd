extends Label

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

onready var world_map = $"/root/Main/WorldMap"
onready var camera = $"/root/Main/Camera"

func _unhandled_input(event):
	call_deferred("_update_text")

func _update_text():
	var mouse_pos = world_map.get_global_mouse_position()
	var terrain_cell = world_map.terrain_grid.get_axial_cell(mouse_pos)
	
	var terrain = world_map.raw_terrain_info(terrain_cell)
	var terrain_id = terrain.terrain_id if terrain else "None"

	var grid_cell = world_map.unit_grid.get_axial_cell(mouse_pos)
	var elevation_info = world_map.elevation.get_info(grid_cell)
	var elevation_str = "origin_hex:%s local_pos:%s raw_level:%s" % [ elevation_info.origin_hex, elevation_info.local_pos, elevation_info.raw_level ] if elevation_info else "N/A"
	
	var structure = world_map.get_structure_at_cell(grid_cell)
	if structure:
		terrain_id += ":" + structure.get_structure_id()

	var zoom = camera.zoom.x
	text = "cell:%s %s terrain:%s x%.2f" % [grid_cell, elevation_str, terrain_id, 1/zoom]