## Recieves icon updates from map objects (units and structures) and 
## dispatches them to individual player map views

extends Reference

## temporary. eventually object ids will be provided by WorldMap when networking is implemented
var object_ids = {}

func register_icon(object, icon_type_id):
	var oid = object_ids.size()
	object_ids[object] = oid

func unregister_icon(object):
	pass

func _icon_updated(update_data, object):
	pass