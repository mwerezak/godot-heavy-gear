extends Control

onready var context_panel = get_parent().find_node('ContextContainer')

var tool_data = [
	{ name = "Spawn Unit", ui_context = "SpawnUnit" },
	{ name = "Delete Unit", ui_context = "DeleteUnit" },
]

#emulate modal group
var active_tool = null

onready var menu_button = $MenuButton

func _ready():
	assert(context_panel)
	var popup = menu_button.get_popup()
	for item in tool_data:
		popup.add_item(item.name)
	popup.connect("index_pressed", self, "_item_selected")

func _item_selected(i):
	if active_tool:
		context_panel.deactivate(active_tool) 
	active_tool = context_panel.activate(tool_data[i].ui_context)

