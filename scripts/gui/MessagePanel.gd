extends PanelContainer

onready var titlebar = $VBoxContainer/TitleContainer
onready var message_window = $VBoxContainer/ScrollContainer
onready var message_container = $VBoxContainer/ScrollContainer/MessageContainer
onready var toggle_button = $VBoxContainer/ToggleSizeButton

var input_handlers = {}

func append(node, input_handler = null):
	message_container.add_child(node)

var _height = 60 setget _set_height, _get_height
func _set_height(h): 
	message_window.rect_min_size.y = h
	toggle_button.text = "v" if h > 0 else ">"

func _get_height(): 
	return message_window.rect_min_size.y

var _saved_height = 0
func _toggle_height():
	if self._height <= 0:
		self._height = _saved_height
	else:
		_saved_height = self._height
		self._height = 0

func _input(event):
	if event.is_action_pressed("click_select") && event.doubleclick:
		_toggle_height()

func _toggle_button_pressed():
	_toggle_height()

var _mouse_captured = false
func _titlebar_gui_input(event):
	if event.is_action_pressed("click_select"):
		_mouse_captured = true
	elif event.is_action_released("click_select"):
		_mouse_captured = false
	
	if _mouse_captured && event is InputEventMouseMotion:
		self._height -= event.relative.y

