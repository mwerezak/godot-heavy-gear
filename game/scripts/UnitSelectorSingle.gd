## a UnitSelector that only selects a single object at a time.
## if multiple objects are being highlighted, subsequent calls to create_selection()
## should cycle through the highlighted objects

extends "UnitSelector.gd"

func _init(hover_factory, selected_factory).(hover_factory, selected_factory):
	pass

func create_selection(select_objects, current_selection=null):
	var found_idx = -1
	if current_selection:
		for object in current_selection.selected:
			found_idx = max(found_idx, select_objects.find(object))
	
	var next_object
	if found_idx < 0:
		# start by selecting the first object
		next_object = select_objects.front()
	else:
		# otherwise, cycle through to the next object
		next_object = select_objects[ (found_idx+1) % select_objects.size() ]
	
	return _create_selection([ next_object ])
