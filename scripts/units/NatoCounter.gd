extends Sprite

const SYMBOLS = {
	infantry = preload("res://icons/units/infantry.png"),
	wheeled_apc = preload("res://icons/units/wheeled_apc.png"),
	tank = preload("res://icons/units/tank.png"),
	gear = preload("res://icons/units/gear.png"),
}

var primary_color setget set_primary_color
var secondary_color setget set_secondary_color
var symbol_foreground_color = Color("#000000") setget set_symbol_foreground_color
var symbol_background_color = Color("#ffffff") setget set_symbol_background_color
var symbol setget set_symbol

onready var sym_sprite = $Symbol
onready var sym_back = $Symbol/Background
onready var sec_stripe = $Stripe

func set_symbol(symbol_id):
	symbol = symbol_id
	sym_sprite.texture = SYMBOLS[symbol_id]

func set_primary_color(color):
	primary_color = color
	self_modulate = color

func set_secondary_color(color):
	secondary_color = color
	if color != null:
		sec_stripe.self_modulate = secondary_color
		sec_stripe.show()
	else:
		sec_stripe.hide()

func set_symbol_foreground_color(color):
	symbol_foreground_color = color
	sym_sprite.self_modulate = color

func set_symbol_background_color(color):
	symbol_background_color = color
	sym_back.self_modulate = color