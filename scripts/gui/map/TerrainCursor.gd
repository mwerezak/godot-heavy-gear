extends Sprite

const Constants = preload("res://scripts/Constants.gd")

onready var hex_coords_label = $HexCoordPanel/HexCoordLabel

onready var elevation_panel = $ElevationPanel
onready var elevation_label = $ElevationPanel/VBoxContainer/ElevationLabel

func _ready():
	z_as_relative = false
	z_index = Constants.HUD_ZLAYER

var world_map
var min_cell
var padding

func setup(world_map):
	self.world_map = world_map

	var min_cell
	var max_cell
	for terrain_cell in world_map.all_terrain_cells():
		var offset_cell = world_map.terrain_grid.axial_to_offset(terrain_cell)
		if !min_cell: min_cell = offset_cell
		if !max_cell: max_cell = offset_cell
		min_cell.x = min(min_cell.x, offset_cell.x)
		min_cell.y = min(min_cell.y, offset_cell.y)
		max_cell.x = max(max_cell.x, offset_cell.x)
		max_cell.y = max(max_cell.y, offset_cell.y)

	self.min_cell = min_cell
	max_cell -= min_cell
	print(max_cell)
	padding = ("%d" % max(max_cell.x, max_cell.y)).length()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		
		## don't snap to blank hexes
		if world_map && world_map.has_point(mouse_pos):
			position = world_map.terrain_grid.snap_to_grid(mouse_pos)
			
			var terrain_cell = world_map.terrain_grid.get_offset_cell(mouse_pos)
			hex_coords_label.text = _format_hexloc(terrain_cell)

			#var terrain = world_map.get_terrain_at_world(mouse_pos)
			#if terrain && terrain.elevation && terrain.elevation.level:
			#	elevation_label.text = "%.2+f u" % terrain.elevation.level ##TODO units formatting
			#	elevation_panel.show()
			#else:
			#	elevation_panel.hide()

func _format_hexloc(hex_coords):
	return "%0*d%0*d" % [ padding, hex_coords.x - min_cell.x, padding, hex_coords.y - min_cell.y ]
