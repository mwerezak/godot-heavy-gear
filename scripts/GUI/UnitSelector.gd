extends Reference

const UnitSelection = preload("UnitSelection.gd")

## Note: any created overlays are transient, and can be deleted at any time.
## we don't need to use weak references here since we track overlays using a Dictionary
## but anyone accessing overlays from the outside should be aware of this.
var _hover_overlay_factory
var _selected_overlay_factory

var _hover_overlays = {}

func _init(hover_overlay_factory, selected_overlay_factory):
	_hover_overlay_factory = hover_overlay_factory
	_selected_overlay_factory = selected_overlay_factory

func highlight_objects(hover_objects, exclude = null):
	for object in hover_objects:
		if !exclude || !exclude.has(object):
			_attach_hover_overlay(object)

func get_highlighted_objects():
	return _hover_overlays.keys()

## returns a new Selection
## should be overriden by subclasses
## by default, just select all highlighted objects
func create_selection(select_objects):
	return _create_selection(select_objects)


func _attach_hover_overlay(object):
	if !_hover_overlays.has(object):
		var overlay = _hover_overlay_factory.create_overlay_node(object)
		object.add_child(overlay)
		object.connect("mouse_exited", self, "_clear_hover_overlay", [object], CONNECT_ONESHOT)
		_hover_overlays[object] = overlay
		
func _clear_hover_overlay(object):
	if _hover_overlays.has(object):
		var overlay = _hover_overlays[object]
		_hover_overlays.erase(object)
		overlay.queue_free()

func _create_selection(objects):
	var selection = UnitSelection.new()
	for object in objects:
		## check if any objects have hover overlays. If they do, remove them.
		_clear_hover_overlay(object)
		var selected_overlay = _selected_overlay_factory.create_overlay_node(object)
		object.add_child(selected_overlay)
		selection.add(object, selected_overlay)
	return selection

#let hover overlays remove themselves on mouse_exited?
#func free():
#	for object in _hover_overlays:
#		var overlay = _hover_overlays[object]
#		overlay.queue_free()
#	.free()
