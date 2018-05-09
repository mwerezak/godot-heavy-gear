extends "UIContextBase.gd"

const UnitSelectorSingle = preload("res://scripts/UnitSelectorSingle.gd")

class OverlayFactory:
	var _overlay_texture
	var _modulate_color
	
	func _init(modulate_color):
		_modulate_color = modulate_color
		
		var overlay_image = Image.new()
		overlay_image.load("res://icons/cadre_64.png")
		
		_overlay_texture = ImageTexture.new()
		_overlay_texture.create_from_image(overlay_image)

	
	func create_overlay_node(object):
		var overlay = Sprite.new()
		overlay.texture = _overlay_texture
		overlay.modulate = _modulate_color
		overlay.scale = Vector2(1,1)*0.25
		overlay.offset = Vector2(0, -45/0.25)
		return overlay


var unit_selector = UnitSelectorSingle.new(
	OverlayFactory.new(Color(0.7, 0.7, 0.7)),  #hover
	OverlayFactory.new(Color(0.35, 1,0, 0.35)) #selected
)

var selection = null

onready var select_button = $MarginContainer/HBoxContainer/Activate

func deactivated(context_manager):
	.deactivated(context_manager)
	selection = null
	select_button.disabled = true

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
		selection = unit_selector.create_selection(objects, selection)
		select_button.disabled = false
		unit_selector.highlight_objects(objects, selection.selected)
	elif event is InputEventMouseMotion:
		var cur_selected = selection.selected if selection else null
		unit_selector.highlight_objects(objects, cur_selected)
