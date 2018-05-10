## base class for UIContexts

extends Control

var context_manager = null 

func _ready():
	hide()

func activated(args):
	_become_active()

func deactivated():
	_become_inactive()

func resumed():
	_become_active()

func suspended():
	_become_inactive()

## convenience function that can be overriden, called on activated() and resumed()
func _become_active():
	show()

## convenience function that can be overriden, called on deactivated() and suspended()
func _become_inactive():
	hide()

func position_input(map, position, event):
	pass

func objects_input(map, objects, event):
	pass