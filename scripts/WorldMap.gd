extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const ArrayMap = preload("res://scripts/helpers/ArrayMap.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const HexGrid = preload("res://scripts/helpers/HexGrid.gd")

const ElevationOverlay = preload("res://scripts/terrain/ElevationOverlay.tscn")

onready var terrain_tilemap = $TileMap
onready var elevation_overlays = $ElevationOverlays

var world_coords setget set_coordinate_system
var terrain_grid
var unit_grid

## maps axial terrain cells -> offset terrain cells used by terrain_tilemap
var terrain_tiles = {}

## These are all Rect2s in world coordinates (i.e. pixels)
var display_rect
var map_bounds

var units = {}
var unit_locs = ArrayMap.new() #1-to-many

var structures = {}
var structure_locs = {} #1-to-1

var roads = {}
var road_cells = {}

## elevation map object
var elevation

func set_coordinate_system(coords):
	world_coords = coords
	terrain_grid = coords.terrain_grid
	unit_grid = coords.unit_grid

func load_map(map_loader):
	map_bounds = map_loader.map_bounds
	display_rect = map_loader.display_rect
	modulate = map_loader.global_lighting

	## setup terrain tiles
	terrain_tilemap.z_as_relative = false
	terrain_tilemap.z_index = Constants.TERRAIN_ZLAYER
	terrain_tilemap.cell_size = world_coords.terrain_grid.cell_spacing
	terrain_tilemap.position = world_coords.terrain_grid.position - world_coords.terrain_grid.cell_spacing/2 #center tiles on grid points
	terrain_tilemap.cell_half_offset = TileMap.HALF_OFFSET_X
	terrain_tilemap.tile_set = map_loader.terrain_tileset
	
	for offset_cell in map_loader.terrain_indexes:
		var axial_cell = world_coords.terrain_grid.offset_to_axial(offset_cell)
		terrain_tiles[axial_cell] = offset_cell

		var tile_idx = map_loader.terrain_indexes[offset_cell]
		terrain_tilemap.set_cellv(offset_cell, tile_idx)

	## setup terrain elevation and elevation overlays
	elevation = map_loader.terrain_elevation

	var ul = world_coords.unit_grid.get_offset_cell(display_rect.position)
	var lr = world_coords.unit_grid.get_offset_cell(display_rect.end + world_coords.unit_grid.cell_size)
	var elevation_overlay_cells = HexUtils.get_rect(Rect2(ul, lr - ul))
	for offset_cell in elevation_overlay_cells:
		var grid_cell = world_coords.unit_grid.offset_to_axial(offset_cell)
		var elevation_info = elevation.get_info(grid_cell)
		var terrain_cell = world_coords.get_terrain_cell(grid_cell)
		
		if terrain_tiles.has(terrain_cell):
			var terrain_tile = terrain_tiles[terrain_cell]
			var offset_terrain = world_coords.terrain_grid.axial_to_offset(terrain_cell)
			var overlay_color = map_loader.overlay_colors[offset_terrain] if map_loader.overlay_colors.has(offset_terrain) else null

			var overlay = ElevationOverlay.instance()
			overlay.set_color(overlay_color)
			overlay.setup(elevation_info)
			elevation_overlays.add_child(overlay)

	## setup structures
	for structure in map_loader.structures:
		add_structure(structure)

	## setup roads
	for road in map_loader.roads:
		add_child(road)

		roads[road] = road.footprint
		for grid_cell in road.footprint:
			road_cells[grid_cell] = road

	## setup scatters
	var scatter_grid = HexGrid.new()
	scatter_grid.cell_size = world_coords.terrain_grid.cell_size
	for hex_pos in map_loader.scatter_spawners:
		scatter_grid.position = world_coords.terrain_grid.offset_to_world(hex_pos)
		var spawner = map_loader.scatter_spawners[hex_pos]
		for scatter in spawner.create_scatters(self, scatter_grid, world_coords.terrain_grid.cell_spacing.x/2.0):
			add_child(scatter)
	scatter_grid.queue_free()
	
	## setup clouds overlay
	var clouds = map_loader.clouds_overlay
	clouds.set_display_rect(display_rect)
	add_child(clouds)

## Terrain Cells

func raw_terrain_info(terrain_cell):
	if !terrain_tiles.has(terrain_cell): return null
	
	var offset_cell = terrain_tiles[terrain_cell]
	var tile_idx = terrain_tilemap.get_cellv(offset_cell)
	
	if tile_idx < 0: return null #outside of map
	
	var lookup_id = terrain_tilemap.tile_set.tile_get_name(tile_idx)
	return GameData.get_terrain_by_lookup_id(lookup_id)

func get_terrain_at_world(world_pos):
	var grid_cell = world_coords.unit_grid.get_axial_cell(world_pos)
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

func has_point(world_pos):
	if !map_bounds.has_point(world_pos):
		return false
	
	var terrain_cell = world_coords.terrain_grid.get_axial_cell(world_pos)
	return terrain_tiles.has(terrain_cell)

## Unit Grid Cells

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

func has_grid_cell(cell_pos):
	var world_pos = world_coords.unit_grid.axial_to_world(cell_pos)
	return has_point(world_pos)

func get_neighbors(cell_pos):
	var neighbors = []
	for other_pos in HexUtils.get_neighbors(cell_pos).values():
		if has_grid_cell(other_pos):
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

func all_units():
	return units.keys()

func _unit_cell_position_changed(old_pos, new_pos, unit):
	units[unit] = new_pos
	unit_locs.move(old_pos, new_pos, unit)
	_update_object_position(unit, new_pos)

func _update_object_position(object, grid_cell):
	var world_pos = world_coords.unit_grid.axial_to_world(grid_cell)
	object.position = world_pos

func add_structure(struct):
	struct.world_map = self

	## first check that we can add this structure
	for grid_cell in struct.footprint:
		if !has_grid_cell(grid_cell):
			print("WARNING: structure extends off map at ", unit_grid.axial_to_offset(grid_cell))
			return
		
		if structure_locs.has(grid_cell):
			print("WARNING: structure already present at cell ", unit_grid.axial_to_offset(grid_cell))
			return

	structures[struct] = struct.footprint
	for grid_cell in struct.footprint:
		structure_locs[grid_cell] = struct

	add_child(struct.create_sprite()) ##temporary

func get_structure_at_cell(grid_cell):
	return structure_locs[grid_cell] if structure_locs.has(grid_cell) else null

## return true if a unit can pass from a given cell into another
func unit_can_pass(unit, movement_mode, from_cell, to_cell):
	## check that to_cell is actually on the map
	var to_world = world_coords.unit_grid.axial_to_world(to_cell)
	var from_world = world_coords.unit_grid.axial_to_world(from_cell)
	var midpoint = 0.5*(to_world + from_world)
	if !has_point(to_world) || !has_point(midpoint):
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
	if !has_grid_cell(dest_cell):
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