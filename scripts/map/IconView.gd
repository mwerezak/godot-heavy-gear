extends Node2D

const UnitIcon = preload("res://scripts/units/UnitIcon.tscn")
const StructureIcon = preload("res://scripts/structures/StructureIcon.gd")
const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")

const UnitIntel = preload("res://scripts/units/UnitIntel.gd")
const StructureIntel = preload("res://scripts/structures/StructureIntel.gd")


var object_icons = {}
var scatter_icons = []

func update_icon(object_intel):
	var oid = object_intel.get_object_id()
	if !object_icons.has(oid):
		var icon = _create_icon(object_intel)
		object_icons[oid] = icon
		add_child(icon)
	object_icons[oid].update(object_intel)

func _create_icon(object_intel):
	if object_intel is StructureIntel:
		return StructureIcon.new()
	if object_intel is UnitIntel:
		return UnitIcon.instance()

func create_scatter_icons(scatters):
	for scatter_data in scatters:
		var scatter = TerrainScatter.new(scatter_data.info)
		scatter.position = scatter_data.position
		scatter_icons.push_back(scatter)
		add_child(scatter)