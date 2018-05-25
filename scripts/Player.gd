extends Node

export(String) var display_name
export(String) var faction_id

var primary_color
var secondary_color

var faction setget set_faction

func _ready():
	 set_faction(Factions.get_info(faction_id))

func set_faction(new_faction):
	faction_id = new_faction.faction_id
	faction = new_faction
	
	if !primary_color:
		primary_color = faction.primary_color
	if !secondary_color:
		secondary_color = faction.secondary_color