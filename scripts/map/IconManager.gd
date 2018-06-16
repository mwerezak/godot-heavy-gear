## Recieves icon updates from map objects (units and structures) and 
## dispatches them to individual player map views

extends Reference

## temporary. eventually object ids will be provided by WorldMap when networking is implemented
var icon_ids = {}

func create_unit_icon(unit):
	pass

func create_structure_icon(struct):
	var icon_id = icon_ids.size()
	icon_ids[struct] = icon_id

	for player in GameSession.all_players():
		player.create_icon(icon_id, "StructureIcon")

	struct.connect("icon_update", self, "_icon_update", [struct])
	struct.call_deferred("update_icon")

func _icon_update(update_data, object):
	var icon_id = icon_ids[object]
	for player in GameSession.all_players():
		player.update_icon(icon_id, update_data)
