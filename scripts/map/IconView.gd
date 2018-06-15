extends Node2D

const ICON_TYPES = {
	UnitIcon = preload("UnitIcon.tscn"),
}

var icons = {}

func create_icon(unit_id, icon_type_id):
	var icon_type = ICON_TYPES[icon_type_id]
	var icon
	if icon_type is PackedScene:
		icon = icon_type.instance()
	elif icon_type is Script:
		icon = icon_type.new()
	else:
		assert(false)

	icons[unit_id] = icon