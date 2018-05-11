extends Sprite

onready var world = $".."
onready var loc_label = $Transparent/LocLabel

var hex_position setget set_hex_position, get_hex_position

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = world.get_global_mouse_position()
		
		## the actual terrain cell is a box that covers the upper 3/4 of the hex
		## but we want the cursor to highlight a hex when the mouse is in the center
		mouse_pos.y -= world.TERRAIN_HEIGHT/8
		
		## don't snap to blank hexes
		if world.point_on_map(mouse_pos):
			var hex_pos = world.terrain.world_to_map(mouse_pos)
			set_hex_position(hex_pos)
			loc_label.text = _format_hexloc(hex_pos)

func _format_hexloc(hex_pos):
	var map_rect = world.terrain.get_used_rect()
	var map_origin = map_rect.position
	var padding = ("%d" % max(map_rect.size.x - 1, map_rect.size.y - 1)).length()
	return "%0*d%0*d" % [ padding, hex_pos.x - map_origin.x, padding, hex_pos.y - map_origin.y ]

func set_hex_position(hex):
	hex_position = hex
	global_position = world.terrain.map_to_world(hex)

func get_hex_position():
	return hex_position