extends Node2D

const UnitIcon = preload("res://scripts/units/UnitIcon.tscn")
const StructureIcon = preload("res://scripts/structures/StructureIcon.gd")
const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")

const OBJECT_ICON_TYPES = {
	preload("res://scripts/units/Unit.gd"): UnitIcon,
	preload("res://scripts/structures/Structure.gd"): StructureIcon
}

var object_icons = {}
var scatter_icons = []

func update_icon(object_id, object_type, update_data):
	if !object_icons.has(object_id):
		var icon_type = OBJECT_ICON_TYPES[object_type]
		var icon = icon_type.instance() if icon_type is PackedScene else icon_type.new()
		object_icons[object_id] = icon
		add_child(icon)
	object_icons[object_id].update(update_data)

func create_scatter_icons(scatters):
	for scatter_data in scatters:
		var scatter = TerrainScatter.new(scatter_data.info)
		scatter.position = scatter_data.position
		scatter_icons.push_back(scatter)
		add_child(scatter)