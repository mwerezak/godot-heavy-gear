extends Reference

const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")

const ScatterSpawner = preload("res://scripts/terrain/ScatterSpawner.gd")
const Structure = preload("res://scripts/structures/Structure.gd")

const SegmentBuilder = preload("res://scripts/terrain/SegmentBuilder.gd")
const RoadComparer = preload("res://scripts/terrain/Road.gd").ConnectionComparer
const Road = preload("res://scripts/terrain/Road.tscn")

const ElevationMap = preload("res://scripts/terrain/ElevationMap.gd")

var source_map
var world_coords
var map_seed

var map_extents #map rect in offset coords
var map_bounds  #playable area of the map in pixel coords
var display_rect #displayable area of the map in pixel coords

var global_lighting
var terrain_tileset
var clouds_overlay

var terrain_data
var terrain_elevation

var structures
var roads

func _init(world_coords, map_scene):
	self.world_coords = world_coords

	source_map = map_scene.instance()
	map_seed = source_map.map_seed.hash()
	rand_seed(map_seed) #initialize seed
	
	global_lighting = source_map.global_lighting
	terrain_tileset = GameData.get_terrain_tileset() #source_map.terrain_tileset
	
	clouds_overlay = source_map.get_node("CloudsOverlay").duplicate() #TODO avoid duplicating nodes
	clouds_overlay.randomize_scroll()

	## determine the map bounds
	map_extents = source_map.map_extents

	var vertical_margin = Vector2(0, world_coords.terrain_grid.cell_size.y/4) #extend the margin so that only the point parts are cut off
	var map_ul = world_coords.terrain_grid.offset_to_world(map_extents.position) - vertical_margin
	var map_lr = world_coords.terrain_grid.offset_to_world(map_extents.end) + vertical_margin
	display_rect = Rect2(map_ul, map_lr - map_ul)

	#unit cells must be entirely contained within the map bounds
	var unit_margins = world_coords.unit_grid.cell_size
	map_bounds = Rect2(display_rect.position + unit_margins, display_rect.size - unit_margins*2)
	
	## extract terrain data
	var editor_map = source_map.get_node("Terrain")
	terrain_data = _generate_terrain(editor_map)
	
	## structures
	var struct_map = source_map.get_node("Structures")
	structures = _generate_structures(struct_map)
	
	## generate roads
	var road_map = source_map.get_node("Roads")
	var builder = SegmentBuilder.new(world_coords.unit_grid, RoadComparer)
	var road_segments = builder.build_segments(road_map)

	roads = []
	for grid_cells in road_segments:
		var road = Road.instance()
		road.setup(world_coords, grid_cells)
		roads.push_back(road)
	
	## extract elevation data
	var elevation_map = source_map.get_node("Elevation")
	var raw_elevation = _extract_elevation(elevation_map)

	var axial_elevation = {}
	for offset_cell in terrain_data:
		var axial_cell = world_coords.terrain_grid.offset_to_axial(offset_cell)
		axial_elevation[axial_cell] = (
			raw_elevation[offset_cell] 
			if raw_elevation.has(offset_cell) else 0
		)

	terrain_elevation = ElevationMap.new(world_coords)
	terrain_elevation.load_elevation_map(axial_elevation)

## rebuild cached terrain indexes and overlays
func _generate_terrain(editor_terrain_map):
	var editor_tileset = editor_terrain_map.get_tileset()
	
	var terrain_data = {}
	for hex_cell in editor_terrain_map.get_used_cells():
		## generate terrain tile index
		var editor_tile_idx = editor_terrain_map.get_cellv(hex_cell)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = GameData.get_terrain(terrain_id)

		var tile_id = RandomUtils.get_weighted_random(terrain_info.tiles)
		var lookup_id = terrain_info.lookup_ids[tile_id]
		var terrain_tile_idx = terrain_tileset.find_tile_by_name(lookup_id)
		var tile_info = GameData.get_tile(tile_id)
		
		## generate terrain hex overlay
		var scatter_seed = hash(hex_cell) ^ map_seed
		var spawner = ScatterSpawner.new(tile_id, scatter_seed)

		terrain_data[hex_cell] = {
			lookup_id = lookup_id,
			tile_idx = terrain_tile_idx,
			overlay_color = tile_info.overlay_color,
			scatter_spawner = spawner,
		}
	return terrain_data

func _generate_structures(struct_map):
	var struct_set = struct_map.get_tileset()

	var structures = []
	for cell_pos in struct_map.get_used_cells():
		var index = struct_map.get_cellv(cell_pos)
		var struct_id = struct_set.tile_get_name(index)
		var struct_info = GameData.get_structure_info(struct_id)
		
		var struct = Structure.new()
		struct.set_structure_info(struct_info)

		var anchor_cell = world_coords.unit_grid.offset_to_axial(cell_pos)
		struct.cell_position = anchor_cell
		structures.push_back(struct)
	return structures

## TODO MOVE THIS TO STRUCTURE
func _get_structure_footprint(structure, offset_cell, anchor_cell):
	var footprint_cells = []


	return footprint_cells

func _extract_elevation(elevation_map):
	var elevation_tileset = elevation_map.get_tileset()

	var raw_elevation = {}
	for hex_cell in elevation_map.get_used_cells():
		var idx = elevation_map.get_cellv(hex_cell)
		var raw_str = elevation_tileset.tile_get_name(idx)
		var elevation = raw_str.split("=", true, 1)[1].to_float()
		raw_elevation[hex_cell] = elevation
	return raw_elevation
