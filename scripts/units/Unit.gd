extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

signal cell_position_changed(old_position, new_position)

## the grid cell that the unit is located in
var cell_position setget set_cell_position, get_cell_position
var facing = 0 setget set_facing, get_facing

#distance from this unit's base to the ground (in distance units), for hovering/flying units
var altitude = 0 setget set_altitude, get_altitude

var faction setget set_faction
var player_owner setget set_player_owner
var unit_info setget set_unit_info
var crew_info setget set_crew_info

onready var world_map
onready var map_marker = $MapMarker

var current_activation = null

func _ready():
	_update_marker()

func set_world_map(map):
	world_map = map

func get_cell_position():
	return cell_position

func set_cell_position(cell_pos):
	var old_pos = cell_position
	cell_position = cell_pos
	emit_signal("cell_position_changed", old_pos, cell_pos)

func set_altitude(alt):
	altitude = alt

func get_altitude():
	return altitude

## The location of the point attached to the bottom of the unit
func get_base_location():
	return world_map.get_ground_location(cell_position) + Vector3(0, 0, altitude)

func _update_marker():
	if map_marker:
		map_marker.set_nato_symbol(unit_info.desc.symbol)
		map_marker.set_facing_marker_visible(has_facing())
		map_marker.set_colors(player_owner.primary_color, faction.secondary_color)

func set_unit_info(info):
	unit_info = info
	_update_marker()

func set_crew_info(crew):
	crew_info = crew

func set_player_owner(new_owner):
	player_owner = new_owner
	if !faction:
		faction = player_owner.default_faction
	_update_marker()

func set_faction(new_faction):
	faction = new_faction
	_update_marker()

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
