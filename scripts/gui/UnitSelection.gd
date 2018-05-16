extends Reference

var selected setget , get_selected
var _selected_overlays = {}

## we're very lax about what can be a selected_overlay
## it is anything that can be queue_free()'d when the Selection is deleted.
## it could be a child of object, but it doesn't have to be.
func add(object, selected_overlay):
	if !_selected_overlays.has(object):
		_selected_overlays[object] = selected_overlay

func has(object):
	return _selected_overlays.has(object)

## updates this selection to include the contents of another selection
func extend(selection):
	for object in selection._selected_overlays:
		var overlay = selection._selected_overlays[object]
		add(object, overlay)

func hide():
	for overlay in _selected_overlays.values():
		overlay.hide()

func show():
	for overlay in _selected_overlays.values():
		overlay.show()

func cleanup():
	for overlay in _selected_overlays.values():
		overlay.queue_free()

func get_selected():
	return _selected_overlays.keys()

func has_all(other):
	return _selected_overlays.has_all(other.selected)

func equals(other):
	if !other: return false
	return other.has_all(self) && self.has_all(other)

## Remove all selected overlays when the selection is deleted.
#func _notification(n):
#	if n == NOTIFICATION_PREDELETE:
#		cleanup()