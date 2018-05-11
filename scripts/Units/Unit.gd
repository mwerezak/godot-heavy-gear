extends Node

const Distances = preload("res://scripts/Game/Distances.gd")

## the diameter of the circle the unit is assumed to occupy, and
## the height of the unit - i.e. its silhouette for targeting purposes (probably more important once elevation is added)
export(float) var base_size = 1.8
export(float) var height = 0.5 

## the grid cell that the unit is located in
export(Vector2) var cell_position = Vector2() setget set_cell_position
export(int) var facing = 0 setget set_facing

export(String) var unit_type = "dummy" #reference a unit type in UnitModels.gd
var unit_info

onready var world_map = get_parent()
onready var map_marker = $MapMarker

func _init():
	unit_info = UnitTypes.INFO[unit_type]

func _ready():
	var pixel_radius = Distances.units2pixels(base_size/2)
	map_marker.set_footprint_radius(pixel_radius)

func set_cell_position(cell_pos):
	if world_map:
		cell_position = cell_pos
		map_marker.position = world_map.get_grid_pos(cell_position)

## not all units use facing. infantry, for example
func has_facing():
	return facing == null

func set_facing(dir):
	facing = dir