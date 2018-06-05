extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const UnitActivation = preload("res://scripts/units/UnitActivation.gd")

## colors for ownerless units
const DEFAULT_PRIMARY_COLOR = Color(0.8, 0.8, 0.8)
const DEFAULT_SECONDARY_COLOR = Color(0.6, 0.6, 0.6)

signal cell_position_changed(old_position, new_position)

## the grid cell that the unit is located in
var cell_position setget set_cell_position, get_cell_position
var facing = 0 setget set_facing, get_facing

#distance from this unit's base to the ground (in distance units), for hovering/flying units
var altitude = 0 setget set_altitude, get_altitude

var faction setget set_faction, get_faction
var player_owner setget set_player
var unit_model setget set_unit_model
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
func true_position():
	return world_map.get_ground_location(cell_position) + Vector3(0, 0, altitude)

func _update_marker():
	if map_marker:
		map_marker.set_nato_symbol(unit_model.desc.symbol)
		map_marker.set_facing_marker_visible(has_facing())

		var primary_color = DEFAULT_PRIMARY_COLOR
		var secondary_color = DEFAULT_SECONDARY_COLOR
		if player_owner:
			var faction = get_faction()
			primary_color = player_owner.primary_color
			secondary_color = faction.secondary_color if faction else null
		map_marker.set_colors(primary_color, secondary_color)

func get_display_label():
	return crew_info.last_name

func set_unit_model(model):
	unit_model = model
	_update_marker()

func set_crew_info(crew):
	crew_info = crew

func set_player(new_owner):
	var prev_owner = player_owner
	if prev_owner != new_owner:
		if prev_owner:
			prev_owner.release_ownership(self)
		if new_owner:
			new_owner.take_ownership(self)

		player_owner = new_owner
		_update_marker()

func set_faction(new_faction):
	faction = new_faction
	_update_marker()

func get_faction():
	if faction: return faction
	if player_owner: return player_owner.default_faction

## not all units use facing. infantry, for example
func has_facing():
	return unit_model.use_facing()

func set_facing(dir):
	facing = HexUtils.normalize(dir)
	if map_marker:
		map_marker.set_facing(HexUtils.dir2rad(dir))

func get_facing():
	if !has_facing(): return null
	return facing

## the height of the unit - i.e. its silhouette for targeting purposes (probably more important once elevation is added)
func get_height():
	return unit_model.get_height()

## return true if the other unit can pass through this one
func can_pass(other):
	return unit_model.is_infantry() || other.unit_model.is_infantry()

func can_stack(other):
	return false ## currently units are never allowed to stack

## returns the cost in movement points
func get_move_cost(move_mode, from_cell, to_cell):
	var from_world = world_map.unit_grid.axial_to_world(from_cell)
	var to_world = world_map.unit_grid.axial_to_world(to_cell)

	var from_terrain = world_map.get_terrain_at_cell(from_cell)
	var to_terrain = world_map.get_terrain_at_cell(to_cell)
	
	var from_speed = unit_model.get_move_speed_on_terrain(move_mode, from_terrain)
	var to_speed = unit_model.get_move_speed_on_terrain(move_mode, to_terrain)
	
	var distance = world_map.distance_along_ground(from_cell, to_cell)
	return distance/( (from_speed + to_speed)/2.0 )

func max_action_points():
	return unit_model.max_action_points()

func max_movement_points():
	return unit_model.max_movement_points()

func activate():
	current_activation = UnitActivation.new(self)