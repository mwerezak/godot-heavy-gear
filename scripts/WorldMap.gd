extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const ArrayMap = preload("res://scripts/helpers/ArrayMap.gd")

const MapLoader = preload("res://scripts/MapLoader.gd")
const ElevationMap = preload("res://scripts/terrain/ElevationMap.gd")
const ElevationOverlay = preload("res://scripts/terrain/ElevationOverlay.tscn")

## dimensions of terrain hexes
## it is important that these are all multiples of 4, due to the geometry of hex grids
## also, note that for regular hexagons, w = sqrt(3)/2 * h
const TERRAIN_WIDTH  = 64*4 #256
const TERRAIN_HEIGHT = 72*4 #288

const UNITGRID_WIDTH = TERRAIN_WIDTH/4 #64
const UNITGRID_HEIGHT = TERRAIN_HEIGHT/4 #72

const UNITGRID_SIZE = UNITGRID_WIDTH/HexUtils.UNIT_DISTANCE # grid spacing in distance units

export(PackedScene) var source_map

onready var terrain = $TerrainTiles
onready var unit_grid = $UnitGrid
onready var overlay_container = $Overlays

## These are all Rect2s in world coordinates (i.e. pixels)
var map_rect    #the region occupied by the map
var map_bounds  #the displayable boundary of the map
var unit_bounds #the "game" boundary of the map

## data structures to map position -> object
var terrain_overlays = {} #1-to-1
var structure_locs = {} #1-to-1
var road_cells = {}
var unit_locs = ArrayMap.new() #1-to-many

## elevation map object
var elevation

func _ready():
	terrain.set_hex_size(Vector2(TERRAIN_WIDTH, TERRAIN_HEIGHT))
	unit_grid.set_hex_size(Vector2(UNITGRID_WIDTH, UNITGRID_HEIGHT))
	
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
	
	## determine the map bounds
	var cell_bounds = terrain.get_used_rect()
	var cell_size = terrain.cell_size
	var cell_to_pixel = Transform2D().scaled(cell_size)
	
	map_rect = Rect2(cell_to_pixel.xform(cell_bounds.position), cell_to_pixel.xform(cell_bounds.size + Vector2(0.5, 0)))
	
	#cut off the pointy parts of the hexes, so the player sees smooth map edges
	var margins = Vector2(TERRAIN_WIDTH/2, TERRAIN_HEIGHT/4)
	map_bounds = Rect2(map_rect.position + margins, map_rect.size - margins*2)
	
	#unit cells must be entirely contained within the map bounds
	var unit_margins = Vector2(UNITGRID_WIDTH/2, UNITGRID_HEIGHT/4)
	unit_bounds = Rect2(map_bounds.position + unit_margins, map_bounds.size - unit_margins*2)
	
	## setup terrain elevation
	elevation = ElevationMap.new(self)
	elevation.load_hex_map(map_loader.terrain_elevation)
	
	for cell_pos in get_rect_cells(map_rect):
		var world_pos = get_grid_pos(cell_pos)
		var cell_z = elevation.get_elevation(world_pos)
		if cell_z:
			var overlay = ElevationOverlay.instance()
			add_child(overlay)
			overlay.position = world_pos
			overlay.level = cell_z
	
	## setup overlays
	for hex_pos in map_loader.terrain_overlays:
		var overlay = map_loader.terrain_overlays[hex_pos]
		overlay.position = get_terrain_pos(overlay.terrain_hex)
		overlay_container.add_child(overlay)
		terrain_overlays[hex_pos] = overlay
	
	## setup structures
	for cell_pos in map_loader.structures:
		var structure = map_loader.structures[cell_pos]
		_setup_structure(structure, cell_pos)
	
	## setup roads
	for road_segment in map_loader.road_segments:
		add_child(road_segment)
		for cell_pos in road_segment.footprint:
			road_cells[cell_pos] = true
	
	## setup scatters
	for overlay in terrain_overlays.values():
		overlay.setup_scatters(self)

## Initialization

## returns the bounding rectangle in world coords
func get_bounding_rect():
	return map_bounds

func all_terrain_hexes():
	return terrain.get_used_cells()

func _setup_structure(structure, cell_pos):
	structure.world_map = self
	structure.cell_position = cell_pos
	
	var footprint_cells = []
	for rect in structure.get_footprint():
		for cell in HexUtils.get_rect(rect):
			footprint_cells.push_back(cell)
			if !grid_cell_on_map(cell):
				print("WARNING: structure extends off map at ", cell)
				return
			
			if structure_locs.has(cell):
				print("WARNING: structure already present at cell ", cell)
				structure.queue_free()
				return
	
	_set_object_position(structure, cell_pos)
	for cell in footprint_cells:
		structure_locs[cell] = structure

## Terrain Hexes

func get_terrain_hex(world_pos):
	return terrain.world_to_map(terrain.transform.affine_inverse().xform(world_pos))

## returns the position of the hex centre
func get_terrain_pos(hex_pos):
	var hex_origin = terrain.map_to_world(hex_pos)
	var local_pos = hex_origin + terrain.cell_size/2
	return terrain.transform.xform(local_pos)

func raw_terrain_info(hex_pos):
	var tile_idx = terrain.get_cellv(hex_pos)
	return TerrainDefs.get_terrain_info(terrain.get_tileset(), tile_idx)

func get_terrain_at_pos(world_pos):
	var cell_pos = get_grid_cell(world_pos)
	return get_terrain_at(cell_pos)

var _terrain_cache = {}
func get_terrain_at(cell_pos):
	if _terrain_cache.has(cell_pos):
		return _terrain_cache[cell_pos]
	
	var world_pos = get_grid_pos(cell_pos)
	var hex_pos = get_terrain_hex(world_pos)
	
	var info = raw_terrain_info(hex_pos).duplicate()
	if structure_locs.has(cell_pos):
		var s = structure_locs[cell_pos]
		var s_info = s.get_terrain_info()
		if s_info:
			for key in s_info:
				info[key] = s_info[key]
	
	info.has_road = road_cells.has(cell_pos)
	
	_terrain_cache[cell_pos] = info
	return info

func point_on_map(world_pos):
	if !map_bounds.has_point(world_pos):
		return false
	
	var hex_pos = get_terrain_hex(world_pos)
	var tile_id = terrain.get_cellv(hex_pos)
	return tile_id >= 0

## Unit Grid Cells

func get_grid_cell(world_pos):
	var cell_pos = unit_grid.world_to_map(unit_grid.transform.affine_inverse().xform(world_pos))
	return cell_pos

## returns the position of the cell centre
func get_grid_pos(cell_pos):
	var local_pos = unit_grid.map_to_world(cell_pos) + unit_grid.cell_size/2
	return unit_grid.transform.xform(local_pos)

## gets the complete position of a cell in distance units including elevation
func get_ground_location(cell_pos):
	var world_pos = get_grid_pos(cell_pos)
	return Vector3(world_pos.x/HexUtils.UNIT_DISTANCE, world_pos.y/HexUtils.UNIT_DISTANCE, elevation.get_elevation(world_pos))

func get_angle_to(cell_from, cell_to):
	var from_pos = get_grid_pos(cell_from)
	var to_pos = get_grid_pos(cell_to)
	return (to_pos - from_pos).angle()

## gets the closest direction to get from one cell to another
func get_dir_to(cell_from, cell_to):
	return HexUtils.nearest_dir(get_angle_to(cell_from, cell_to))

## returns the distance betwen the centres of two cells, in distance units
func distance_along_ground(cell1, cell2):
	var pos1 = get_ground_location(cell1)
	var pos2 = get_ground_location(cell2)
	return (pos1 - pos2).length()

func path_distance(cell_path):
	var distance = 0
	var last_cell = null
	for next_cell in cell_path:
		if last_cell:
			distance += distance_along_ground(last_cell, next_cell)
		last_cell = next_cell
	return distance

func grid_cell_on_map(cell_pos):
	var world_pos = get_grid_pos(cell_pos)
	if !unit_bounds.has_point(world_pos):
		return false
	return point_on_map(world_pos)

func get_neighbors(cell_pos):
	var neighbors = []
	for other_pos in HexUtils.get_neighbors(cell_pos).values():
		if grid_cell_on_map(other_pos):
			neighbors.push_back(other_pos)
	return neighbors

## gets all grid cells overlapping a rectangle given in pixel coords
func get_rect_cells(world_rect):
	var ul = get_grid_cell(world_rect.position)
	var lr = get_grid_cell(world_rect.end)
	return HexUtils.get_rect(Rect2(ul, lr - ul))

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
	if object.has_method("get_position_offset"):
		world_pos += object.get_position_offset()
	
	## need to place objects inside terrain overlays for YSort to work correctly
	var hex_pos = get_terrain_hex(world_pos)
	var overlay = terrain_overlays[hex_pos]
	if object.get_parent() == null:
		overlay.add_child(object)
	elif overlay != object.get_parent():
		object.get_parent().remove_child(object)
		overlay.add_child(object)
	
	object.set_position(world_pos - overlay.position)

## return true if a unit can pass from a given cell into another
func unit_can_pass(unit, movement_mode, from_cell, to_cell):
	## check that to_cell is actually on the map
	var to_pos = get_grid_pos(to_cell)
	var from_pos = get_grid_pos(from_cell)
	var midpoint = 0.5*(to_pos + from_pos)
	if !point_on_map(to_pos) || !point_on_map(midpoint):
		return false
	
	## check that the terrain is passable
	var dest_info = get_terrain_at(to_cell)
	if dest_info.impassable.has(movement_mode.type_id):
		return false
	
	var midpoint_cell = get_grid_cell(midpoint)
	var midpoint_info = get_terrain_at(midpoint_cell)
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
	var terrain_info = get_terrain_at(to_cell)
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