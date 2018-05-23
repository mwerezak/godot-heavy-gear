extends Label

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

onready var world_map = $"/root/Main/WorldMap"
onready var camera = $"/root/Main/Camera"

func _unhandled_input(event):
	call_deferred("_update_text")

func _update_text():
	var mouse_pos = world_map.get_global_mouse_position()
	var hex_pos = world_map.get_terrain_hex(mouse_pos)
	
	var terrain = world_map.raw_terrain_info(hex_pos)
	var terrain_id = terrain.terrain_id if terrain else "None"

	var cell_pos = world_map.get_grid_cell(mouse_pos)
	var elevation_info = world_map.elevation.get_info(cell_pos)
	var elevation_str = "world_pos:%s grade:%s normal:%s" % [ elevation_info.world_pos, elevation_info.grade, elevation_info.normal ]
	
	var structure = world_map.get_structure_at_cell(cell_pos)
	if structure:
		terrain_id += ":" + structure.get_structure_id()

	var zoom = camera.zoom.x
	text = "cell:%s %s terrain:%s x%.2f" % [cell_pos, elevation_str, terrain_id, 1/zoom]