extends Container

const ContextBase = preload("ContextBase.gd")

var context_stack = []

func _ready():
	var current_scene = get_tree().get_current_scene()

	for child in get_children():
		if child is ContextBase:
			current_scene.ui_context[child.name] = child
			child.context_manager = self
			child.hide()

func get_context(context_name):
	return get_node(context_name)

func activate(context_name, args = null):
	assert(has_node(context_name))
	
	args = args if args else {}
	
	if is_active_or_suspended(context_name):
		return
	
	var active_context = get_active_context()
	if active_context:
		active_context.suspended()
	
	var next_context = get_node(context_name)
	context_stack.push_back(next_context)
	next_context.activated(args)
	
	return get_active_context()

func deactivate(context_name = null):
	if !context_name:
		return deactivate_current()
	
	var search_context = get_node(context_name)
	var idx = context_stack.find_last(search_context)
	if idx >= 0:
		search_context.deactivated()
		context_stack.remove(idx)
		if idx != 0 && context_stack.size() == idx:
			get_active_context().resumed()
	
	return get_active_context()

func deactivate_current():
	var active_context = get_active_context()
	if active_context:
		active_context.deactivated()
		context_stack.pop_back()
		
		var next_context = get_active_context()
		if next_context:
			next_context.resumed()
	
	return get_active_context()

func is_active_or_suspended(context_name):
	for context in context_stack:
		if context.name == context_name:
			return true
	return false

func is_active(context_name):
	var active_context = get_active_context()
	return active_context && active_context.name == context_name

func get_active_context():
	return context_stack.back() if context_stack.size() > 0 else null

func cell_input_event(world_map, cell_pos, event):
	var active_context = get_active_context()
	if active_context:
		active_context.cell_input(world_map, cell_pos, event)
