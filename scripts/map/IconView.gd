extends Node2D

const TerrainScatter = preload("res://scripts/terrain/TerrainScatter.gd")

const ICON_TYPES = {
	UnitIcon = preload("res://scripts/units/UnitIcon.tscn"),
	StructureIcon = preload("res://scripts/structures/StructureIcon.gd"),
}

var object_icons = {}
var scatter_icons = []



func create_scatter_icons(scatters):
	for scatter_data in scatters:
		var scatter = TerrainScatter.new(scatter_data.info)
		scatter.position = scatter_data.position
		scatter_icons.push_back(scatter)
		add_child(scatter)