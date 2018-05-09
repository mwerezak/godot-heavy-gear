## base class for UIContexts

extends Control

func _ready():
	hide()

func activated(context_manager, args):
	show()

func deactivated(context_manager):
	hide()

func resumed(context_manager):
	show()

func suspended(context_manager):
	hide()

func position_input(map, position, event):
	pass

func objects_input(map, objects, event):
	pass