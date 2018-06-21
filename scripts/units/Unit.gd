extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const UnitIcon = preload("UnitIcon.tscn")

signal cell_position_changed(old_pos, new_pos)
signal update_icon(update_data)


## the grid cell that the unit is located in
var cell_position setget set_cell_position, get_cell_position
var facing = 0 setget set_facing, get_facing

#distance from this unit's base to the ground (in distance units), for hovering/flying units
var altitude = 0 setget set_altitude, get_altitude

var faction setget set_faction, get_faction
var owner_side setget set_side
var unit_model setget set_unit_model
var crew_info setget set_crew_info

var world_map

var uid #unqiue ID used to reference units remotely

func _init():
	uid = get_instance_id()

func set_world_map(map):
	world_map = map

func get_cell_position():
	return cell_position

func set_cell_position(cell_pos):
	var old_pos = cell_position
	cell_position = cell_pos
	emit_signal("cell_position_changed", old_pos, cell_pos)
	update_icon_position()

func set_altitude(alt):
	altitude = alt

func get_altitude():
	return altitude

## The location of the point attached to the bottom of the unit
func get_true_position():
	return world_map.get_true_position(cell_position) + Vector3(0, 0, altitude)

func get_display_label():
	return crew_info.last_name

func set_unit_model(model):
	unit_model = model
	update_icon_appearance()
	update_icon_facing()

func set_crew_info(crew):
	crew_info = crew

func set_side(new_owner):
	var prev_owner = owner_side
	if prev_owner != new_owner:
		if prev_owner:
			prev_owner.release_ownership(self)
		if new_owner:
			new_owner.take_ownership(self)

		owner_side = new_owner
		update_icon_appearance()

func get_player_owner():
	return owner_side.player if owner_side else null

func set_faction(new_faction):
	faction = new_faction
	update_icon_appearance()

func get_faction():
	if faction: return faction
	if owner_side: return owner_side.default_faction

## not all units use facing. infantry, for example
func has_facing():
	return unit_model.use_facing()

func set_facing(dir):
	facing = HexUtils.normalize(dir)
	update_icon_facing()

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
	var from_terrain = world_map.get_terrain_at_cell(from_cell)
	var to_terrain = world_map.get_terrain_at_cell(to_cell)
	
	var from_speed = unit_model.get_move_speed_on_terrain(move_mode, from_terrain)
	var to_speed = unit_model.get_move_speed_on_terrain(move_mode, to_terrain)
	
	var from_true = world_map.get_true_position(from_cell)
	var to_true = world_map.get_true_position(to_cell)
	
	var distance = (from_true - to_true).length()
	return distance/( (from_speed + to_speed)/2.0 )

func max_action_points():
	return unit_model.max_action_points()

func max_movement_points():
	return unit_model.max_movement_points()

## icon updates
func update_icon():
	update_icon_appearance()
	update_icon_position()
	update_icon_facing()

func update_icon_position():
	if !world_map: return
	
	var icon_pos = world_map.unit_grid.axial_to_world(cell_position)
	emit_signal("update_icon", { position = icon_pos })

func update_icon_facing():
	var update_data
	if has_facing():
		var icon_facing = HexUtils.dir2rad(facing)
		update_data = { has_facing = true, facing = icon_facing }
	else:
		update_data = { has_facing = false }
	emit_signal("update_icon", update_data)

func update_icon_appearance():
	if !unit_model: return
	
	var primary_color = null
	if owner_side:
		primary_color = owner_side.primary_color
	
	var secondary_color = null
	var faction = get_faction()
	if faction:
		secondary_color = faction.secondary_color
	elif owner_side:
		secondary_color = owner_side.primary_color
	
	var update_data = {
		has_facing = has_facing(),
		unit_symbol = unit_model.desc.symbol,
		primary_color = primary_color,
		secondary_color = secondary_color,
	}
	emit_signal("update_icon", update_data)
