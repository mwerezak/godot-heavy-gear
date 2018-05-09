extends Control

onready var container = $VBoxContainer

var ui_contexts = {}
var context_stack = []

func register(ui_context, context_name):
	assert(!ui_contexts.has(context_name))
	
	ui_contexts[context_name] = ui_context
	ui_context.context_manager = self
	ui_context.name = context_name
	ui_context.hide()
	
	container.add_child(ui_context)

func activate(context_name, args = null):
	args = args if args else {}
	
	if is_active_or_suspended(context_name):
		return
	
	var active_context = get_active_context()
	if active_context:
		active_context.suspended()
	
	var next_context = ui_contexts[context_name]
	context_stack.push_back(next_context)
	next_context.activated(args)

func deactivate(context_name = null):
	if !context_name:
		return deactivate_current()
	
	var search_context = ui_contexts[context_name]
	var idx = context_stack.find_last(search_context)
	if idx >= 0:
		search_context.deactivated()
		context_stack.remove(idx)
		if idx != 0 && context_stack.size() == idx:
			get_active_context().resumed()

func deactivate_current():
	var active_context = get_active_context()
	if active_context:
		active_context.deactivated()
		context_stack.pop_back()
		
		var next_context = get_active_context()
		if next_context:
			next_context.resumed()

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