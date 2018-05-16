extends Control

onready var ui_context = $"/root/MainMap".find_node("ContextContainer") #this sucks

var tool_data = [
	{ name = "Spawn Unit", ui_context = "dev_spawn_unit" },
	{ name = "Delete Unit", ui_context = "dev_delete_unit" },
]

onready var menu_button = $MenuButton

func _ready():
	assert(ui_context)
	menu_button.add_item("Dev Tools")
	for item in tool_data:
		menu_button.add_item(item.name)

func _item_selected(i):
	for item in tool_data:
		ui_context.deactivate(item.ui_context)
	ui_context.activate(tool_data[i-1].ui_context)
	menu_button.select(0)
