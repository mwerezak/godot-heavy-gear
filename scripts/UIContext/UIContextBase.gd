## base class for UIContexts

extends Control

var context_manager = null 

func _ready():
	hide()

func activated(args):
	show()

func deactivated():
	hide()

func resumed():
	show()

func suspended():
	hide()

func position_input(map, position, event):
	pass

func objects_input(map, objects, event):
	pass