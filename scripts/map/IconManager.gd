## Recieves icon updates from map objects (units and structures) and 
## dispatches them to individual player map views

extends Reference

## temporary. eventually object ids will be provided by WorldMap when networking is implemented

func create_unit_icon(unit):
	for player in GameSession.all_players():
		player.create_icon(unit, "UnitIcon")

	unit.connect("icon_update", self, "_icon_update", [unit])
	unit.call_deferred("update_icon")

func create_structure_icon(struct):
	for player in GameSession.all_players():
		player.create_icon(struct, "StructureIcon")

	struct.connect("icon_update", self, "_icon_update", [struct])
	struct.call_deferred("update_icon")

func _icon_update(update_data, object):
	for player in GameSession.all_players():
		player.update_icon(object, update_data)

func delete_icon(object):
	for player in GameSession.all_players():
		player.delete_icon(object)