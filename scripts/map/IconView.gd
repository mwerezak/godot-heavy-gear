extends Node2D

const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")

const ICON_TYPES = {
	UnitIcon = preload("res://scripts/units/UnitIcon.tscn"),
	StructureIcon = preload("res://scripts/structures/StructureIcon.gd"),
}

var object_icons = {}
var scatter_icons = []

func create_icon(object, icon_type_id):
	if object_icons.has(object): return

	var icon_type = ICON_TYPES[icon_type_id]
	var icon
	if icon_type is PackedScene:
		icon = icon_type.instance()
	elif icon_type is Script:
		icon = icon_type.new()
	else:
		assert(false)

	icon.name = "Icon#%d"%hash(object) ##temp
	object_icons[object] = icon
	add_child(icon)

func update_icon(object, update_data):
	object_icons[object].update(update_data)

func get_icon(object):
	if object_icons.has(object):
		return object_icons[object]

func delete_icon(object):
	var icon = object_icons[object]
	object_icons.erase(object)
	remove_child(icon)
	icon.queue_free()

func create_scatter_icons(scatters):
	for scatter_data in scatters:
		var scatter = TerrainScatter.new(scatter_data.info)
		scatter.position = scatter_data.position
		scatter_icons.push_back(scatter)
		add_child(scatter)