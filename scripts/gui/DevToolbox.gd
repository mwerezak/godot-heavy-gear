extends Control

onready var context_panel = get_tree().get_current_scene().find_node('ContextContainer')

var tool_data = [
	{ name = "Spawn Unit", ui_context = "SpawnUnit" },
	{ name = "Delete Unit", ui_context = "DeleteUnit" },
]

onready var menu_button = $MenuButton

func _ready():
	assert(context_panel)
	var popup = menu_button.get_popup()
	for item in tool_data:
		popup.add_item(item.name)
	popup.connect("index_pressed", self, "_item_selected")

func _item_selected(i):
	for item in tool_data:
		context_panel.deactivate(item.ui_context)
	context_panel.activate(tool_data[i].ui_context)

