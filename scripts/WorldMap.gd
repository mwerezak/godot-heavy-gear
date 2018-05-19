extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const ArrayMap = preload("res://scripts/helpers/ArrayMap.gd")

const MapLoader = preload("res://scripts/MapLoader.gd")

## dimensions of terrain hexes
## it is important that these are all multiples of 4, due to the geometry of hex grids
## also, note that for regular hexagons, w = sqrt(3)/2 * h
const TERRAIN_WIDTH  = 64*4 #256
const TERRAIN_HEIGHT = 74*4 #296
static func get_terrain_cell_size():
	return Vector2(TERRAIN_WIDTH, TERRAIN_HEIGHT*3/4) #because Vector2() can't be const :(

const UNITGRID_WIDTH = 16*4 #64
const UNITGRID_HEIGHT = 18*4 #72
static func get_unit_grid_cell_size():
	return Vector2(UNITGRID_WIDTH, UNITGRID_HEIGHT*3/4)

const UNITGRID_SIZE = UNITGRID_WIDTH/HexUtils.UNIT_DISTANCE # grid spacing in distance units

export(PackedScene) var source_map

onready var terrain = $TerrainTiles
onready var unit_grid = $UnitGrid
onready var overlay_container = $Overlays


## data structures to map position -> object
var terrain_overlays = {} #1-to-1
var structure_locs = {} #1-to-1
var unit_locs = ArrayMap.new() #1-to-many

func _ready():
	terrain.cell_size = get_terrain_cell_size()
	unit_grid.cell_size = get_unit_grid_cell_size()
	
	terrain.z_as_relative = false
	terrain.z_index = Constants.TERRAIN_ZLAYER
	
	## load the source map
	var map_loader = MapLoader.new(self)
	map_loader.load_map(source_map)
	
	modulate = map_loader.global_lighting
	
	## setup terrain tiles
	for hex_pos in map_loader.terrain_indexes:
		var idx = map_loader.terrain_indexes[hex_pos]
		terrain.set_cellv(hex_pos, idx)
	
	## setup overlays
	for hex_pos in map_loader.terrain_overlays:
		var overlay = map_loader.terrain_overlays[hex_pos]
		_setup_overlay(overlay, hex_pos)
	
	## setup structures
	for cell_pos in map_loader.structures:
		var structure = map_loader.structures[cell_pos]
		_setup_structure(structure, cell_pos)
	
	## setup scatters
	for overlay in terrain_overlays.values():
		overlay.setup_scatters()


## Initialization

## returns the bounding rectangle in world coords
func get_bounding_rect():
	var cell_bounds = terrain.get_used_rect()
	var cell_size = terrain.cell_size
	var cell_to_pixel = Transform2D(Vector2(cell_size.x, 0), Vector2(0, cell_size.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)

func _setup_overlay(overlay, hex_pos):
	overlay.world_map = self
	overlay.position = get_terrain_pos(overlay.terrain_hex)
	
	overlay_container.add_child(overlay)
	terrain_overlays[hex_pos] = overlay

func _setup_structure(structure, cell_pos):
	structure.world_map = self
	structure.cell_position = cell_pos
	
	var footprint_cells = []
	for rect in structure.get_footprint():
		for cell in HexUtils.get_rect(rect):
			footprint_cells.push_back(cell)
			if structure_locs.has(cell):
				print("WARNING: structure already present at cell ", cell)
				structure.queue_free()
				return
	
	_set_object_position(structure, cell_pos)
	for cell in footprint_cells:
		structure_locs[cell] = structure

## Terrain Hexes

func get_terrain_hex(world_pos):
	return terrain.world_to_map(world_pos)

## returns the position of the hex centre
func get_terrain_pos(hex_pos):
	var hex_origin = terrain.map_to_world(hex_pos)
	return hex_origin + terrain.cell_size/2

func get_terrain_at(world_pos):
	var hex_pos = get_terrain_hex(world_pos)
	return get_terrain_at_hex(hex_pos)

func get_terrain_at_hex(hex_pos):
	var tile_idx = terrain.get_cellv(hex_pos)
	return TerrainDefs.get_terrain_info(terrain.get_tileset(), tile_idx)

func point_on_map(world_pos):
	var hex_pos = get_terrain_hex(world_pos)
	var tile_id = terrain.get_cellv(hex_pos)
	return tile_id >= 0

## Unit Grid Cells

func get_grid_cell(world_pos):
	var cell_pos = unit_grid.world_to_map(world_pos)
	return cell_pos

## returns the position of the cell centre
func get_grid_pos(cell_pos):
	return unit_grid.map_to_world(cell_pos) + unit_grid.cell_size/2

func get_angle_to(cell_from, cell_to):
	var from_pos = get_grid_pos(cell_from)
	var to_pos = get_grid_pos(cell_to)
	return (to_pos - from_pos).angle()

## gets the closest direction to get from one cell to another
func get_dir_to(cell_from, cell_to):
	return HexUtils.nearest_dir(get_angle_to(cell_from, cell_to))

## returns the distance betwen the centres of two cells, in distance units
func grid_distance(cell1, cell2):
	var pos1 = get_grid_pos(cell1)
	var pos2 = get_grid_pos(cell2)
	var pixel_dist = (pos1 - pos2).length()
	return HexUtils.pixels2units(pixel_dist)

func path_distance(cell_path):
	var distance = 0
	var last_cell = null
	for next_cell in cell_path:
		if last_cell:
			distance += grid_distance(last_cell, next_cell)
		last_cell = next_cell
	return distance

func grid_cell_on_map(cell_pos):
	return point_on_map(get_grid_pos(cell_pos))

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
	unit_locs.push_back(unit.cell_position, unit)
	_set_object_position(unit, unit.cell_position)

func get_units_at_cell(cell_pos):
	if !unit_locs.has(cell_pos):
		return []
	return unit_locs.get_values(cell_pos)

func get_structure_at_cell(cell_pos):
	return structure_locs[cell_pos] if structure_locs.has(cell_pos) else null

func get_objects_at_cell(cell_pos):
	return get_units_at_cell(cell_pos)

func _unit_cell_position_changed(old_pos, new_pos, unit):
	unit_locs.move(old_pos, new_pos, unit)
	_set_object_position(unit, new_pos)

func _set_object_position(object, cell_pos):
	var world_pos = get_grid_pos(cell_pos)
	
	## need to place objects inside terrain overlays for YSort to work correctly
	var hex_pos = get_terrain_hex(world_pos)
	var overlay = terrain_overlays[hex_pos]
	if object.get_parent() == null:
		overlay.add_child(object)
	elif overlay != object.get_parent():
		object.get_parent().remove_child(object)
		overlay.add_child(object)
	
	object.set_position(world_pos - overlay.position)

func get_terrain_info(cell_pos):
	var world_pos = get_grid_pos(cell_pos)
	var hex_pos = get_terrain_hex(world_pos)
	
	var info = get_terrain_at_hex(hex_pos)
	if structure_locs.has(cell_pos):
		var s = structure_locs[cell_pos]
		var s_info = s.get_terrain_info()
		if s_info:
			info = info.duplicate()
			for key in s_info:
				info[key] = s_info[key]
	
	return info

## return true if a unit can pass from a given cell into another
func unit_can_pass(unit, movement_mode, from_cell, to_cell):
	## check that to_cell is actually on the map
	var to_pos = get_grid_pos(to_cell)
	var from_pos = get_grid_pos(from_cell)
	var midpoint = 0.5*(to_pos + from_pos)
	if !point_on_map(to_pos) || !point_on_map(midpoint):
		return false
	
	## check that the terrain is passable
	var dest_info = get_terrain_info(to_cell)
	if dest_info.impassable.has(movement_mode.type_id):
		return false
	
	var midpoint_cell = get_grid_cell(midpoint)
	var midpoint_info = get_terrain_info(midpoint_cell)
	if midpoint_info.impassable.has(movement_mode.type_id):
		return false
	
	## make sure there are no objects that could block us
	for object in get_objects_at_cell(to_cell):
		if object != unit && !object.can_pass(unit):
			return false

	return true

## return true if a unit can stop (i.e. finish movement) in a given cell
func unit_can_place(unit, to_cell):
	## check that to_cell is actually on the map
	if !grid_cell_on_map(to_cell):
		return false
	
	## check that the terrain is passable
	var allowed = false
	var terrain_info = get_terrain_info(to_cell)
	for movement_mode in unit.unit_info.get_movement_modes():
		if !terrain_info.impassable.has(movement_mode.type_id):
			allowed = true
			break
	
	if !allowed: return false
	
	## make sure there are no objects that could block us
	for object in get_objects_at_cell(to_cell):
		if object != unit && !object.can_stack(unit):
			return false
	
	return true