## creates selection markers and attaches them to 2D objects

extends Reference

var overlay_scene

var _overlays = {}

var _marked = {}
var _selected = {}
var _hovering = {}

func _init(overlay_scene):
	self.overlay_scene = overlay_scene

func mark_object(object):
	_marked[object] = true
	_update_overlay(object)

func unmark_object(object):
	_marked.erase(object)
	_update_overlay(object)

func set_hovering(objects):
	var update = objects + _hovering.keys()

	_hovering.clear()
	for object in objects:
		_hovering[object] = true

	for object in update:
		_update_overlay(object)

func set_selected(objects):
	var update = objects + _selected.keys()

	_selected.clear()
	for object in objects:
		_selected[object] = true

	for object in update:
		_update_overlay(object)

func get_selected():
	return _selected.keys()

func _update_overlay(object):
	if !_overlays.has(object):
		var new_overlay = overlay_scene.instance()
		new_overlay.name = "SelectionOverlay#%d"%hash(self)
		object.add_child(new_overlay)
		_overlays[object] = new_overlay

	var overlay = _overlays[object]
	if _selected.has(object):
		overlay.set_state(overlay.STATE_SELECTED)
	elif _hovering.has(object):
		overlay.set_state(overlay.STATE_HOVER)
	elif _marked.has(object):
		overlay.set_state(overlay.STATE_MARKED)
	else:
		overlay.set_state(overlay.STATE_DISABLED)

func clear():
	_marked.clear()
	_selected.clear()
	_hovering.clear()
	for overlay in _overlays.values():
		overlay.queue_free()
	_overlays.clear()