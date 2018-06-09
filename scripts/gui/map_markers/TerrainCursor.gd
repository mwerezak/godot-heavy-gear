extends Sprite

const Constants = preload("res://scripts/Constants.gd")

onready var hex_coords_label = $HexCoordPanel/HexCoordLabel

onready var elevation_panel = $ElevationPanel
onready var elevation_label = $ElevationPanel/VBoxContainer/ElevationLabel

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _unhandled_input(event):
	var world_map = get_parent().world_map
	if !world_map: return
	
	if event is InputEventMouseMotion:
		var mouse_pos = world_map.get_global_mouse_position()
		
		## don't snap to blank hexes
		if world_map.point_on_map(mouse_pos):
			position = world_map.terrain_grid.snap_to_grid(mouse_pos)
			var offset_cell = world_map.terrain_grid.get_offset_cell(mouse_pos)
			hex_coords_label.text = _format_hexloc(world_map, offset_cell)

			#var terrain = world_map.get_terrain_at_world(mouse_pos)
			#if terrain && terrain.elevation && terrain.elevation.level:
			#	elevation_label.text = "%.2+f u" % terrain.elevation.level ##TODO units formatting
			#	elevation_panel.show()
			#else:
			#	elevation_panel.hide()

func _format_hexloc(world_map, hex_coords):
	var map_rect = world_map.terrain_tilemap.get_used_rect()
	var map_origin = map_rect.position
	var padding = ("%d" % max(map_rect.size.x - 1, map_rect.size.y - 1)).length()
	return "%0*d%0*d" % [ padding, hex_coords.x - map_origin.x, padding, hex_coords.y - map_origin.y ]
