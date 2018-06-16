extends Node2D

const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")

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

func create_scatter_icons(scatters):
	for scatter_data in scatters:
		var scatter = TerrainScatter.new(scatter_data.info)
		scatter.position = scatter_data.position
		add_child(scatter)