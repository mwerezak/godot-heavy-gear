extends "UIContextBase.gd"

const UnitSelectorSingle = preload("res://scripts/UnitSelectorSingle.gd")

class OverlayFactory:
	var _overlay_texture
	var _modulate_color
	
	func _init(modulate_color):
		_modulate_color = modulate_color
		
		var overlay_image = Image.new()
		overlay_image.load("res://icons/selection_marker_16.png")
		
		_overlay_texture = ImageTexture.new()
		_overlay_texture.create_from_image(overlay_image)

	
	func create_overlay_node(object):
		var overlay = Sprite.new()
		overlay.texture = _overlay_texture
		overlay.modulate = _modulate_color
		overlay.offset = Vector2(0, -45)
		return overlay

export(Color) var hover_color = Color(0.7, 0.7, 0.7, 0.5)
export(Color) var selected_color = Color(0.35, 1.0, 0.35, 1.0)

var unit_selector = UnitSelectorSingle.new(
	OverlayFactory.new(hover_color),  
	OverlayFactory.new(selected_color)
)

var selection = null setget set_selection

onready var activate_button = $MarginContainer/HBoxContainer/Activate

func deactivated():
	.deactivated()
	set_selection(null)

## if we're hidden, also hide our selection
func hide():
	.hide()
	if selection:
		selection.hide()

func show():
	.show()
	if selection:
		selection.show()

func objects_input(map, objects, event):
	if event.is_action_pressed("click_select"):
		if selection: selection.cleanup()
		var new_selection = unit_selector.create_selection(objects, selection)
		
		#var confirm_selection = new_selection.equals(selection)
		set_selection(new_selection)
		unit_selector.highlight_objects(objects, new_selection.selected)
		#if confirm_selection: _activate_button_pressed()
		
	elif event is InputEventMouseMotion:
		var cur_selected = selection.selected if selection else null
		unit_selector.highlight_objects(objects, cur_selected)

func set_selection(s):
	selection = s
	activate_button.disabled = (s == null)

func _activate_button_pressed():
	var activate_selection = selection
	set_selection(null)
	context_manager.activate("move_unit", { selection = activate_selection })
