extends Sprite

const SYMBOLS = {
	infantry = preload("res://icons/units/nato/infantry.png"),
	wheeled_apc = preload("res://icons/units/nato/wheeled_apc.png")
}

var color setget set_color, get_color
var symbol setget set_symbol

onready var sym_sprite = $Symbol

func set_symbol(symbol_id):
	symbol = symbol_id
	sym_sprite.texture = SYMBOLS[symbol_id]

func set_color(color):
	self_modulate = color

func get_color():
	return self_modulate