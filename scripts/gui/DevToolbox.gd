extends Control

onready var ui_context = $"/root/Main".find_node("ContextContainer") #this sucks

var tool_data = [
	{ name = "Spawn Unit", ui_context = "dev_spawn_unit" },
	{ name = "Delete Unit", ui_context = "dev_delete_unit" },
]

onready var menu_button = $MenuButton

func _ready():
	assert(ui_context)
	var popup = menu_button.get_popup()
	for item in tool_data:
		popup.add_item(item.name)
	popup.connect("index_pressed", self, "_item_selected")

func _item_selected(i):
	for item in tool_data:
		ui_context.deactivate(item.ui_context)
	ui_context.activate(tool_data[i].ui_context)

