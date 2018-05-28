extends Node

export(String) var display_name
export(String) var faction_id

export(Color) var primary_color
export(Color) var secondary_color

var default_faction setget set_faction

func _ready():
	 set_faction(GameData.get_faction(faction_id))

func set_faction(new_faction):
	faction_id = new_faction.faction_id
	default_faction = new_faction
	
	if !primary_color:
		primary_color = default_faction.primary_color
	if !secondary_color:
		secondary_color = default_faction.secondary_color