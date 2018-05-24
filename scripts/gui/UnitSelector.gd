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

func highlight_objects(hover_objects):
	for object in _hover_overlays:
		if !hover_objects.has(object):
			_clear_hover_overlay(object)

	for object in hover_objects:
		if !_hover_overlays.has(object):
			var overlay = _hover_overlay_factory.create_overlay_node(object)
			_hover_overlays[object] = overlay
			object.add_child(overlay)

func get_highlighted_objects():
	return _hover_overlays.keys()

func _clear_hover_overlay(object):
	if _hover_overlays.has(object):
		var overlay = _hover_overlays[object]
		_hover_overlays.erase(object)
		overlay.queue_free()

## returns a new Selection
## should be overriden by subclasses
## by default, just select all highlighted objects
func create_selection(select_objects):
	return _create_selection(select_objects)

func _create_selection(objects):
	var selection = UnitSelection.new()
	for object in objects:
		## check if any objects have hover overlays. If they do, remove them.
		_clear_hover_overlay(object)
		var selected_overlay = _selected_overlay_factory.create_overlay_node(object)
		object.add_child(selected_overlay)
		selection.add(object, selected_overlay)
	return selection
