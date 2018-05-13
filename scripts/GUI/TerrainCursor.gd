extends Sprite

const Constants = preload("res://scripts/Constants.gd")

onready var world_map = get_parent()
onready var loc_label = $Transparent/LocLabel

var hex_position setget set_hex_position, get_hex_position

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = world_map.get_global_mouse_position()
		
		## don't snap to blank hexes
		if world_map.point_on_map(mouse_pos):
			var hex_pos = world_map.terrain.world_to_map(mouse_pos)
			set_hex_position(hex_pos)
			loc_label.text = _format_hexloc(hex_pos)

func _format_hexloc(hex_pos):
	var map_rect = world_map.terrain.get_used_rect()
	var map_origin = map_rect.position
	var padding = ("%d" % max(map_rect.size.x - 1, map_rect.size.y - 1)).length()
	return "%0*d%0*d" % [ padding, hex_pos.x - map_origin.x, padding, hex_pos.y - map_origin.y ]

func set_hex_position(hex):
	hex_position = hex
	global_position = world_map.terrain.map_to_world(hex)

func get_hex_position():
	return hex_position