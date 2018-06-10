extends PanelContainer

onready var resize_window = $VBoxContainer/HBoxContainer/ScrollContainer
onready var message_container = $VBoxContainer/HBoxContainer/ScrollContainer/MessageContainer
onready var title_button = $VBoxContainer/TitleContainer/TitleButton
onready var toggle_button = $VBoxContainer/HBoxContainer/ToggleSizeButton

var input_handlers = {} #TODO input handling not implemented yet

func _ready():
	self._height = 60

func append(node, input_handler = null):
	message_container.add_child(node)

var _height = 60 setget _set_height, _get_height
func _set_height(h): 
	resize_window.rect_min_size.y = h
	if h > 0:
		toggle_button.text = "v"
		toggle_button.disabled = false
	else:
		toggle_button.text = "^"
		toggle_button.disabled = _saved_height <= 0

func _get_height(): 
	return resize_window.rect_min_size.y

var _saved_height = 0
func _toggle_height():
	if self._height <= 0:
		self._height = _saved_height
	else:
		_saved_height = self._height
		self._height = 0

func _toggle_button_pressed():
	_toggle_height()

var _mouse_captured = false
func _title_button_down(): _mouse_captured = true
func _title_button_up(): _mouse_captured = false

var _has_mouse = false
func _title_button_mouse_entered(): _has_mouse = true
func _title_button_mouse_exited(): _has_mouse = false

func _input(event):
	if _mouse_captured && event is InputEventMouseMotion:
		self._height -= event.relative.y
	if _has_mouse && event.is_action_pressed("click_select") && event.doubleclick:
		_toggle_height()


