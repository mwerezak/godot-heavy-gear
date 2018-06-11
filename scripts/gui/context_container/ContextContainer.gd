extends Container

const ContextBase = preload("ContextBase.gd")

class ContextFrame:
	signal context_return(rval)
	signal deactivated

	var node
	var name setget , get_name
	var container
	var saved_state = null

	func _init(container, context_node):
		self.container = container
		self.node = context_node

	func get_name():
		return node.name

	func activated(args):
		node.activated(self, args)

	func deactivated():
		node.deactivated()
		emit_signal("deactivated")

	func suspended():
		node.suspended()
		saved_state = node.export_state()

	func resumed():
		node.import_state(saved_state)
		node.resumed()

	func context_return(rval):
		emit_signal("context_return", rval)
		container.deactivate(self)

var context_stack = []

func _ready():
	for child in get_children():
		if child is ContextBase:
			child.hide()

func get_context(context_name):
	return get_node(context_name)

func activate(context_name, args = null):
	assert(has_node(context_name))
	
	args = args if args else {}
	
	var active_context = get_active_context()
	if active_context:
		active_context.suspended()
	
	var next_context = ContextFrame.new(self, get_node(context_name))
	context_stack.push_back(next_context)
	next_context.activated(args)
	
	return next_context

func deactivate(context_frame):
	var idx = context_stack.find_last(context_frame)
	if idx >= 0:
		context_frame.deactivated()
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
		active_context.node.cell_input(world_map, cell_pos, event)
