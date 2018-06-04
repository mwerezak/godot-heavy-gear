## base class for UIContexts

extends Control

signal context_return(rval)

var context_manager

var REQUIRED = Reference.new() ## marker for required arguments

## when activated, any properties specified here are loaded from args
var load_properties = {}

func _ready():
	hide()
	set_process_input(false)

## activates the context and returns a GDFunctionScriptState whose completed signal can be yielded on.
func context_call(args_dict = {}):
	context_manager.activate(name, args_dict)
	var rval = yield(self, "context_return")
	return rval

## deactivates the context and returns a value to anyone yielding on the context
func context_return(rval = null):
	context_manager.deactivate(name)
	emit_signal("context_return", rval)

func activated(args):
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

