extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

## the grid cell that the unit is located in
var cell_position setget set_cell_position, get_cell_position
var facing = 0 setget set_facing, get_facing

var faction setget set_faction
var unit_info setget set_unit_info
var crew_info setget set_crew_info

onready var world_map = get_parent()
onready var map_marker = $MapMarker

var current_activation = null

func _update_marker():
	if map_marker:
		map_marker.set_nato_symbol(unit_info.desc.symbol)
		map_marker.set_facing_marker_visible(has_facing())

func set_unit_info(info):
	unit_info = info
	call_deferred("_update_marker")

func set_crew_info(crew):
	crew_info = crew

func set_faction(new_faction):
	faction = new_faction
	map_marker.set_colors(faction.primary_color, faction.secondary_color)

func get_cell_position():
	return cell_position

func set_cell_position(cell_pos):
	cell_position = cell_pos
	if world_map:
		position = world_map.get_grid_pos(cell_pos) #snap to grid

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
	return unit_info.is_infantry() || other.unit_info.is_infantry()

func can_stack(other):
	return false ## currently units are never allowed to stack
