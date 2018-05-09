extends "UIContextBase.gd"

onready var select_button = $MarginContainer/HBoxContainer/Activate

var selected = null

func activated(context_manager, args):
	.activated(context_manager, args)
	
	selected = null
	select_button.disabled = true

#func objects_input(map, objects, event):
