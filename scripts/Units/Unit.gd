extends Node

const Distance = preload("res://scripts/Game/Distance.gd")
const Direction = preload("res://scripts/Game/Direction.gd")

## the grid cell that the unit is located in
export(Vector2) var cell_position = Vector2() setget set_cell_position
export(int) var facing = 0 setget set_facing, get_facing

export(String) var unit_type = "dummy" #reference a unit type in UnitModels.gd
var unit_info

onready var world_map = get_parent()
onready var map_marker = $MapMarker

func _init():
	unit_info = UnitTypes.INFO[unit_type]

func _ready():
	var base_size = get_base_size()
	var pixel_radius = Distance.units2pixels(base_size/2)
	map_marker.set_footprint_radius(pixel_radius)
	map_marker.set_facing_marker_visible(has_facing())

func set_cell_position(cell_pos):
	if world_map:
		cell_position = cell_pos
		map_marker.position = world_map.get_grid_pos(cell_position)

## not all units use facing. infantry, for example
func has_facing():
	return unit_info.use_facing

func set_facing(dir):
	facing = Direction.normalize(dir)
	if map_marker:
		map_marker.set_facing(Direction.dir2rad(dir))

func get_facing():
	if !has_facing(): return null
	return facing

## the diameter of the circle the unit is assumed to occupy, in distance units
func get_base_size():
	return unit_info.base_size

## the height of the unit - i.e. its silhouette for targeting purposes (probably more important once elevation is added)
func get_height():
	return unit_info.height