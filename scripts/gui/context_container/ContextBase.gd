## base class for UIContexts

extends Control

var context_frame
var context_manager

var REQUIRED = Reference.new() ## marker for required arguments

## when activated, any properties specified here are loaded from args
var load_properties = {}

func _ready():
	hide()
	set_process_input(false)

## deactivates the context and returns a value to anyone yielding on the context
func context_return(rval = null):
	context_frame.context_return(rval)

func activated(frame, args):
	context_frame = frame
	context_manager = frame.container
	for property in load_properties:
		var default = load_properties[property]
		assert( !(typeof(default) == TYPE_OBJECT && default == REQUIRED && !args.has(property)) )
		set(property, args[property] if args.has(property) else default)
	_setup()
	_become_active()

## called after arguments are loaded but before _become_active() is called.
func _setup():
	pass ## to be overridden by subtypes

func deactivated():
	_become_inactive()

func resumed():
	_become_active()

func suspended():
	_become_inactive()

## convenience function that can be overriden, called on activated() and resumed()
func _become_active():
	show()
	set_process_input(true)

## convenience function that can be overriden, called on deactivated() and suspended()
func _become_inactive():
	hide()
	set_process_input(false)

func cell_input(world_map, cell_pos, event):
	pass

func export_state():
	var state = {}
	for info in get_property_list():
		state[info.name] = get(info.name)
	return state

func import_state(state):
	for key in state:
		set(key, state[key])
	