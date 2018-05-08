extends Node

var ui_contexts = {}

var context_stack = []

func register(ui_context):
	assert(!ui_contexts.has(ui_context.name))
	ui_contexts[ui_context.name] = ui_context
	ui_context.hide()
	add_child(ui_context)

func activate(context_name):
	if is_active_or_suspended(context_name):
		return
	
	var active_context = get_active_context()
	if active_context:
		active_context.suspended(self)
	
	var next_context = ui_contexts[context_name]
	context_stack.push_back(next_context)
	next_context.activated(self)

func deactivate(context_name):
	if !context_name:
		return deactivate_current()
	
	var search_context = ui_contexts[context_name]
	var idx = context_stack.find_last(search_context)
	if idx >= 0:
		search_context.deactivated(self)
		context_stack.remove(idx)
		if idx != 0 && context_stack.size() == idx:
			get_active_context().resumed(self)

func deactivate_current():
	var active_context = get_active_context()
	if active_context:
		active_context.deactivated(self)
		context_stack.pop_back()
		
		var next_context = get_active_context()
		if next_context:
			next_context.resumed(self)

func is_active_or_suspended(context_name):
	for context in context_stack:
		if context.name == context_name:
			return true
	return false

func is_active(context_name):
	var active_context = get_active_context()
	return active_context && active_context.name == context_name

func get_active_context():
	return context_stack.back()

func position_input_event(map, position, event):
	var active_context = get_active_context()
	if active_context:
		active_context.position_input(map, position, event)

func objects_input_event(map, objects, event):
	var active_context = get_active_context()
	if active_context:
		active_context.objects_input(map, objects, event)