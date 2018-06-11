## a simple context that displays a message to the player

extends "ContextBase.gd"

var message_text setget set_message_text
var button_text setget set_button_text

onready var label = $MarginContainer/HBoxContainer/Label
onready var done_button = $MarginContainer/HBoxContainer/DoneButton

func _init():
	load_properties = {
		message_text = "Press the button to continue.",
		button_text = "Done",
	}

func _become_active():
	._become_active()
	done_button.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
		_done_button_pressed()

func _done_button_pressed():
	context_return()

func set_message_text(text):
	message_text = text
	label.text = text

func set_button_text(text):
	button_text = text
	done_button.text = text
