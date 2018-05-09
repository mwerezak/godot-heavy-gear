extends "UIContextBase.gd"

const marker_hover_color = Color(1,1,1)
const marker_selected_color = Color(0.25, 0.8, 0.25)

onready var select_button = $MarginContainer/HBoxContainer/Activate

var selected = null setget set_selected, get_selected

func activated(context_manager, args):
	.activated(context_manager, args)
	selected = null
	select_button.disabled = true

func resumed(context_manager):
	.resumed(context_manager)
	select_button.disabled = (get_selected() == null)

func objects_input(map, objects, event):
	var selected = get_selected()
	if event.is_action_pressed("click_select"):
		var idx = -1
		if selected:
			idx = objects.find(selected)
		
		var next_selected
		if idx < 0:
			#start with the first of the highlighed objects
			set_selected(objects.front())
		elif objects.size() > 1:
			#cycle through highlighted objects
			var next_object = objects[ (idx+1) % objects.size() ]
			var prev_object = selected
			set_selected(next_object)
			highlight_object(prev_object)
		
		
	elif event is InputEventMouseMotion:
		for object in objects:
			if object != selected:
				highlight_object(object)

func set_selected(object):
	var cur_selected = get_selected()
	if cur_selected != object:
		if cur_selected:
			cur_selected.hide_selected_marker()
		
		selected = weakref(object)
		if object:
			object.show_selected_marker(marker_selected_color)
			select_button.disabled = false
		else:
			select_button.disabled = true

func get_selected():
	return selected.get_ref() if selected else null

func highlight_object(object):
	object.show_selected_marker(marker_hover_color)
	object.connect("mouse_exited", self, "_on_object_mouse_exited", [object], CONNECT_ONESHOT)

func _on_object_mouse_exited(object):
	if object != get_selected():
		object.hide_selected_marker()