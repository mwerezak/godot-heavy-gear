extends Node

const HexUtils = preload("res://scripts/HexUtils.gd")

## the grid cell that the unit is located in
export(Vector2) var cell_position = Vector2() setget set_cell_position, get_cell_position
export(int) var facing = 0 setget set_facing, get_facing

export(String) var display_name
export(String) var unit_type = "dummy_infantry" setget set_unit_type #reference a unit type in UnitModels.gd
var unit_info

onready var world_map = get_parent()
onready var map_marker = $MapMarker

var current_activation = null

func _ready():
	var primary_color = Color("#355570") 
	var secondary_color = Color("#FFC300")
	map_marker.set_colors(primary_color, secondary_color)

func _update_marker():
	if map_marker:
		map_marker.set_nato_symbol(unit_info.get_symbol())
		map_marker.set_facing_marker_visible(has_facing())

func set_unit_type(model_id):
	unit_info = UnitTypes.get_info(model_id)
	unit_type = model_id
	
	display_name = unit_info.get_name()
	
	call_deferred("_update_marker")

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
	return unit_info.is_infantry() || other.unit_info.is_infantry()

func can_stack(other):
	return false ## currently units are never allowed to stack
