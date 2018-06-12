## Loads a map from a SceneMap scene.

extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const RandomUtils = preload("res://scripts/helpers/RandomUtils.gd")
const WorldMap = preload("res://scripts/WorldMap.gd")
const ScatterSpawner = preload("res://scripts/terrain/ScatterSpawner.gd")
const SegmentBuilder = preload("res://scripts/terrain/SegmentBuilder.gd")
const Road = preload("res://scripts/terrain/Road.tscn")
const RoadComparer = preload("res://scripts/terrain/Road.gd").ConnectionComparer
const ElevationMap = preload("res://scripts/terrain/ElevationMap.gd")
const CloudsOverlay = preload("res://scripts/terrain/CloudsOverlay.gd")
const Structure = preload("res://scripts/structures/Structure.tscn")

var source_map
var map_seed
var world_grid setget set_world_grid

var map_extents #occupied terrain hexes in offset coords
var map_bounds  #playable map area in pixel coords
var display_rect #displayable map area in pixel coords

var global_lighting
var terrain_tileset
var clouds_overlay

var terrain_indexes
var overlay_colors
var terrain_elevation

var scatter_spawners

var structures = {}
var roads = []

func set_world_grid(grid):
	world_grid = grid

func load_map(map_scene):
	source_map = map_scene.instance()
	map_seed = source_map.map_seed.hash()
	rand_seed(map_seed) #initialize seed
	
	global_lighting = source_map.global_lighting
	terrain_tileset = GameData.get_terrain_tileset() #source_map.terrain_tileset
	
	clouds_overlay = {
		type = source_map.clouds_type,
		texture = source_map.clouds_texture,
		drift_velocity = _randomize_drift(),
	}

	## determine the map bounds
	map_extents = source_map.map_extents
	
	var vertical_margin = Vector2(0, WorldMap.TERRAIN_HEIGHT/4) #extend the margin so that only the point parts are cut off
	var map_ul = world_grid.terrain_grid.offset_to_world(map_extents.position) - vertical_margin
	var map_lr = world_grid.terrain_grid.offset_to_world(map_extents.end) + vertical_margin
	var map_rect = Rect2(map_ul, map_lr - map_ul)
	display_rect = map_rect #displayable map area
	
	#unit cells must be entirely contained within the map bounds
	var unit_margins = world_grid.unit_grid.cell_size
	map_bounds = Rect2(map_rect.position + unit_margins, map_rect.size - unit_margins*2) #playable map area
	
	## extract terrain data
	var editor_map = source_map.get_node("Terrain")
	var terrain_data = _generate_terrain(editor_map)
	terrain_indexes = terrain_data.terrain_indexes
	overlay_colors = terrain_data.overlay_colors
	scatter_spawners = terrain_data.scatter_spawners
	
	## structures
	var struct_map = source_map.get_node("Structures")
	structures = _generate_structures(struct_map)
	
	## generate roads
	var road_map = source_map.get_node("Roads")
	var builder = SegmentBuilder.new(world_grid.unit_grid, RoadComparer)
	var road_segments = builder.build_segments(road_map)
	for grid_cells in road_segments:
		var road = Road.instance()
		road.setup(world_grid, grid_cells)
		roads.push_back(road)
	
	## extract elevation data
	var elevation_map = source_map.get_node("Elevation")
	var raw_elevation = _extract_elevation(elevation_map)

	## any elevation not specified by the elevation map is considered 0
	for hex_cell in terrain_indexes:
		if !raw_elevation.has(hex_cell):
			raw_elevation[hex_cell] = 0

	terrain_elevation = ElevationMap.new(world_grid, raw_elevation)

## rebuild cached terrain indexes and overlays
func _generate_terrain(editor_terrain_map):
	var editor_tileset = editor_terrain_map.get_tileset()
	
	var terrain_indexes = {}
	var overlay_colors = {}
	var scatter_spawners = {}
	for hex_cell in editor_terrain_map.get_used_cells():
		## generate terrain tile index
		var editor_tile_idx = editor_terrain_map.get_cellv(hex_cell)
		var terrain_id = editor_tileset.tile_get_name(editor_tile_idx)
		var terrain_info = GameData.get_terrain(terrain_id)

		var tile_id = RandomUtils.get_weighted_random(terrain_info.tiles)
		var lookup_id = terrain_info.lookup_ids[tile_id]
		var terrain_tile_idx = terrain_tileset.find_tile_by_name(lookup_id)
		terrain_indexes[hex_cell] = terrain_tile_idx
		
		var tile_info = GameData.get_tile(tile_id)
		overlay_colors[hex_cell] = tile_info.overlay_color
		
		## generate terrain hex overlay
		var scatter_seed = hash(hex_cell) ^ map_seed
		var spawner = ScatterSpawner.new(tile_id, scatter_seed)
		scatter_spawners[hex_cell] = spawner

	return {
		terrain_indexes = terrain_indexes,
		overlay_colors = overlay_colors,
		scatter_spawners = scatter_spawners,
	}

func _generate_structures(struct_map):
	var struct_tileset = struct_map.get_tileset()

	var structures = {}
	for cell_pos in struct_map.get_used_cells():
		var index = struct_map.get_cellv(cell_pos)
		var struct_id = struct_tileset.tile_get_name(index)
		var struct_info = GameData.get_structure_info(struct_id)
		
		var struct = Structure.instance()
		struct.name = "%s_0" % struct_id
		struct.set_structure_info(struct_info)
		structures[cell_pos] = struct
	return structures

func _setup_structure(structure, offset_cell):
	structure.world_map = self
	
	var anchor_cell = world_grid.unit_grid.offset_to_axial(offset_cell)
	structure.cell_position = anchor_cell
	
	var footprint_cells = []
	for rect in structure.get_footprint():
		var shifted_rect = Rect2(rect.position + offset_cell, rect.size)
		for offset_cell in HexUtils.get_rect(shifted_rect):
			var grid_cell = world_grid.unit_grid.offset_to_axial(offset_cell)
			footprint_cells.push_back(grid_cell)
			if !grid_cell_on_map(grid_cell):
				print("WARNING: structure extends off map at ", offset_cell)
				return
			
			if structure_locs.has(grid_cell):
				print("WARNING: structure already present at cell ", offset_cell)
				structure.queue_free()
				return

	structure.position = world_grid.unit_grid.axial_to_world(anchor_cell) + structure.get_position_offset()

	structures[structure] = footprint_cells
	for grid_cell in footprint_cells:
		structure_locs[grid_cell] = structure

func _extract_elevation(elevation_map):
	var elevation_tileset = elevation_map.get_tileset()

	var raw_elevation = {}
	for hex_cell in elevation_map.get_used_cells():
		var idx = elevation_map.get_cellv(hex_cell)
		var raw_str = elevation_tileset.tile_get_name(idx)
		var elevation = raw_str.split("=", true, 1)[1].to_float()
		raw_elevation[hex_cell] = elevation
	return raw_elevation

func _randomize_drift():
	var scroll_angle = deg2rad(rand_range(0.0, 360.0))
	var scroll_speed = rand_range(2.5, 5.0) 
	return scroll_speed*Vector2(cos(scroll_angle), sin(scroll_angle))