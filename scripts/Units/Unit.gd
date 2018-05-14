extends Node

const HexUtils = preload("res://scripts/HexUtils.gd")

const MARKER_RADIUS = 16 #pixels

## the grid cell that the unit is located in
export(Vector2) var cell_position = Vector2() setget set_cell_position, get_cell_position
export(int) var facing = 0 setget set_facing, get_facing

export(String) var unit_type = "dummy" #reference a unit type in UnitModels.gd
var unit_info

onready var world_map = get_parent()
onready var map_marker = $MapMarker

func _init():
	unit_info = UnitTypes.get_info(unit_type)

func _ready():
	map_marker.set_footprint_radius(MARKER_RADIUS)
	map_marker.set_facing_marker_visible(has_facing())

func get_cell_position():
	return cell_position

func set_cell_position(cell_pos):
	if world_map:
		cell_position = cell_pos
		map_marker.position = world_map.get_grid_pos(cell_position)

## not all units use facing. infantry, for example
func has_facing():
	return unit_info.use_facing()

func set_facing(dir):
	facing = HexUtils.normalize(dir)
	if map_marker:
		map_marker.set_facing(HexUtils.dir2rad(dir))

func get_facing():
	if !has_facing(): return null
	return facing

## the height of the unit - i.e. its silhouette for targeting purposes (probably more important once elevation is added)
func get_height():
	return unit_info.get_height()

## return true if the other unit can pass through this one
func can_pass(other):
	return unit_info.is_infantry()

func can_stack(other):
	return false ## currently units are never allowed to stack
