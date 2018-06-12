extends Node

const ArrayMap = preload("res://scripts/helpers/ArrayMap.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var world_grid setget set_world_grid

## maps axial terrain cells -> lookup id
var terrain_lookup = {} 

## maps axial terrain cells -> offset terrain cells used by the map
var terrain_tiles = {}

var map_bounds #the playable boundary of the map, in pixel coords

var units = {}
var unit_locs = ArrayMap.new() #1-to-many

var structures = {}
var structure_locs = {} #1-to-1

## TODO generalize line and point terrain elements
var roads = {}
var road_cells = {}

## elevation map object
var elevation

func set_world_grid(grid):
	world_grid = grid

func load_map(world_grid, map_loader):
	map_bounds = map_loader.map_bounds

	## build terrain cell -> tile mapping
	for offset_cell in map_loader.terrain_indexes:
		var axial_cell = world_grid.terrain_grid.offset_to_axial(offset_cell)
		terrain_tiles[axial_cell] = offset_cell

		var tile_idx = map_loader.terrain_indexes[offset_cell]
		var lookup_id = map_loader.terrain_tileset.tile_get_name(tile_idx)
		terrain_lookup[axial_cell] = lookup_id
	
	## setup terrain elevation 
	elevation = map_loader.terrain_elevation

	## setup structures
	for offset_cell in map_loader.structures:
		var structure = map_loader.structures[offset_cell]
		_setup_structure(structure, offset_cell)
	
	## setup roads
	for road in map_loader.roads:
		roads[road] = road.footprint
		for grid_cell in road.footprint:
			road_cells[grid_cell] = road

## Terrain Cells

func raw_terrain_info(terrain_cell):
	if !terrain_lookup.has(terrain_cell): return null

	var lookup_id = terrain_lookup[terrain_cell]
	return GameData.get_terrain_by_lookup_id(lookup_id)

func get_terrain_at_world(world_pos):
	var grid_cell = world_grid.unit_grid.get_axial_cell(world_pos)
	return get_terrain_at_cell(grid_cell)

var _terrain_cache = {}
func get_terrain_at_cell(grid_cell):
	if _terrain_cache.has(grid_cell):
		return _terrain_cache[grid_cell]
	
	var terrain_cell = get_terrain_cell(grid_cell)
	
	var info = raw_terrain_info(terrain_cell)
	if !info: return null
	
	info = info.duplicate()
	info.has_road = road_cells.has(grid_cell)
	info.elevation = elevation.get_info(grid_cell)
	
	if structure_locs.has(grid_cell):
		var s = structure_locs[grid_cell]
		var s_info = s.get_terrain_info()
		if s_info:
			for key in s_info:
				info[key] = s_info[key]
	
	_terrain_cache[grid_cell] = info
	return info

## should be called after anything that modifies terrain
func refresh_terrain(terrain_cell):
	_terrain_cache.erase(terrain_cell)

func point_on_map(world_pos):
	if !map_bounds.has_point(world_pos):
		return false
	
	var terrain_cell = world_grid.terrain_grid.get_axial_cell(world_pos)
	return terrain_lookup.has(terrain_cell)

## Unit Grid Cells

## obtains the terrain cell that contains this grid cell
func get_terrain_cell(grid_cell):
	var world_pos = world_grid.unit_grid.axial_to_world(grid_cell)
	return world_grid.terrain_grid.get_axial_cell(world_pos)

func get_angle_to(cell_from, cell_to):
	var from_pos = world_grid.unit_grid.axial_to_world(cell_from)
	var to_pos = world_grid.unit_grid.axial_to_world(cell_to)
	return (to_pos - from_pos).angle()

## gets the complete 3D position of a cell in distance units including elevation
func get_true_position(cell_pos):
	var info = get_terrain_at_cell(cell_pos)
	return info.elevation.true_pos

## cell_path should be an array of axial cell positions
func path_distance(cell_path):
	var distance = 0
	var last_cell = null
	for next_cell in cell_path:
		if last_cell:
			distance += (get_true_position(last_cell) - get_true_position(next_cell)).length()
		last_cell = next_cell
	return distance

func grid_cell_on_map(cell_pos):
	var world_pos = world_grid.unit_grid.axial_to_world(cell_pos)
	return point_on_map(world_pos)

func get_neighbors(cell_pos):
	var neighbors = []
	for other_pos in HexUtils.get_neighbors(cell_pos).values():
		if grid_cell_on_map(other_pos):
			neighbors.push_back(other_pos)
	return neighbors

## Map Objects

func add_unit(unit):
	unit.world_map = self
	unit.connect("cell_position_changed", self, "_unit_cell_position_changed", [unit])

	var cell_pos = unit.cell_position
	units[unit] = cell_pos
	unit_locs.push_back(cell_pos, unit)
	_update_object_position(unit, cell_pos)
	add_child(unit)

func remove_unit(unit):
	unit.world_map = null
	unit.disconnect("cell_position_changed", self, "_unit_cell_position_changed")

	units.erase(unit)
	unit_locs.remove(unit.cell_position, unit)

	remove_child(unit)

func get_units_at_cell(grid_cell):
	if !unit_locs.has(grid_cell):
		return []
	return unit_locs.get_values(grid_cell)

func get_structure_at_cell(grid_cell):
	return structure_locs[grid_cell] if structure_locs.has(grid_cell) else null

func all_units():
	return units.keys()

func _unit_cell_position_changed(old_pos, new_pos, unit):
	units[unit] = new_pos
	unit_locs.move(old_pos, new_pos, unit)
	_update_object_position(unit, new_pos)

func _update_object_position(object, grid_cell):
	var world_pos = world_grid.unit_grid.axial_to_world(grid_cell)
	if object.has_method("get_position_offset"):
		world_pos += object.get_position_offset()
	object.position = world_pos

## return true if a unit can pass from a given cell into another
func unit_can_pass(unit, movement_mode, from_cell, to_cell):
	## check that to_cell is actually on the map
	var to_world = world_grid.unit_grid.axial_to_world(to_cell)
	var from_world = world_grid.unit_grid.axial_to_world(from_cell)
	var midpoint = 0.5*(to_world + from_world)
	if !point_on_map(to_world) || !point_on_map(midpoint):
		return false
	
	## check that the terrain is passable
	var dest_info = get_terrain_at_cell(to_cell)
	if dest_info.impassable.has(movement_mode.type_id):
		return false
	
	var midpoint_info = get_terrain_at_world(midpoint)
	if midpoint_info.impassable.has(movement_mode.type_id):
		return false
	
	## make sure there are no objects that could block us
	for object in get_units_at_cell(to_cell):
		if object != unit && !object.can_pass(unit):
			return false

	return true

## return true if a unit can stop (i.e. finish movement) in a given cell
func unit_can_place(unit, dest_cell):
	## check that dest_cell is actually on the map
	if !grid_cell_on_map(dest_cell):
		return false
	
	## check that the terrain is passable
	var allowed = false
	var terrain_info = get_terrain_at_cell(dest_cell)
	for movement_mode in unit.unit_model.get_movement_modes():
		if !terrain_info.impassable.has(movement_mode.type_id):
			allowed = true
			break
	
	if !allowed: return false
	
	## make sure there are no objects that could block us
	for object in get_units_at_cell(dest_cell):
		if object != unit && !object.can_stack(unit):
			return false
	
	return true