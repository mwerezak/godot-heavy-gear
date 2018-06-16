extends Node2D

const ICON_TYPES = {
	UnitIcon = preload("res://scripts/units/UnitIcon.gd"),
	StructureIcon = preload("res://scripts/structures/StructureIcon.gd"),
}

var icons = {}

func create_icon(icon_id, icon_type_id):
	assert(!icons.has(icon_id))

	var icon_type = ICON_TYPES[icon_type_id]
	var icon
	if icon_type is PackedScene:
		icon = icon_type.instance()
	elif icon_type is Script:
		icon = icon_type.new()
	else:
		assert(false)

	icon.name = "Icon#%d"%icon_id
	icons[icon_id] = icon
	add_child(icon)

func update_icon(icon_id, update_data):
	icons[icon_id].update(update_data)

func delete_icon(icon_id):
	var icon = icons[icon_id]
	icons.erase(icon)
	remove_child(icon)
	icon.queue_free()


const HexGrid = preload("res://scripts/helpers/HexGrid.gd")

func create_scatters(world_map):
	var terrain_grid = world_map.world_coords.terrain_grid

	var scatter_grid = HexGrid.new()
	scatter_grid.cell_size = terrain_grid.cell_size
	for terrain_cell in world_map.scatter_spawners:
		scatter_grid.position = terrain_grid.axial_to_world(terrain_cell)
		var spawner = world_map.scatter_spawners[terrain_cell]
		for scatter in spawner.create_scatters(world_map, scatter_grid, terrain_grid.cell_spacing.x/2.0):
			add_child(scatter)
	scatter_grid.queue_free()