## Recieves icon updates from map objects (units and structures) and 
## dispatches them to individual player map views

extends Reference

var object_icons = {}

func register_icon(object, icon_type):
	pass

func unregister_icon(object):
	pass

func _icon_updated(update_data, object):
	pass