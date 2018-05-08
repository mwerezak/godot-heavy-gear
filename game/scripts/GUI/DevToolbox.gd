extends Control

onready var ui_context = $"/root/MainMap".find_node("UIContextPanel") #this sucks

var tool_data = [
	{ name = "Spawn Unit", ui_context = "dev_spawn_unit" },
	{ name = "Delete Unit", ui_context = "dev_delete_unit" },
]
var buttons = {}

func _ready():
	assert(ui_context)
	for item in tool_data:
		var button = Button.new()
		button.text = item.name
		button.toggle_mode = true
		button.connect("toggled", self, "button_toggled", [button])
		buttons[button] = item.ui_context
		$HBoxContainer.add_child(button)

func button_toggled(pressed, button):
	if pressed:
		for other in buttons:
			if other != button && other.pressed:
				other.pressed = false
				var context_name = buttons[other]
				ui_context.deactivate(context_name)
		
		var context_name = buttons[button]
		ui_context.activate(context_name)
	else:
		var context_name = buttons[button]
		ui_context.deactivate(context_name)


