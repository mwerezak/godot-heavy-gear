extends Sprite

const SYMBOLS = {
	infantry = preload("res://icons/units/nato/infantry.png"),
	wheeled_apc = preload("res://icons/units/nato/wheeled_apc.png"),
	tank = preload("res://icons/units/nato/tank.png"),
	gear = preload("res://icons/units/nato/gear.png"),
}

var primary_color setget set_primary_color
var secondary_color setget set_secondary_color
var symbol setget set_symbol

onready var sym_sprite = $Symbol
onready var sec_stripe = $Stripe

func set_symbol(symbol_id):
	symbol = symbol_id
	sym_sprite.texture = SYMBOLS[symbol_id]

func set_primary_color(color):
	primary_color = color
	self_modulate = color

func set_secondary_color(color):
	# force the alpha of the secondary color to be slightly transparent, for some blending
	secondary_color = Color(color.r, color.g, color.b, min(0.7, color.a))
	if color != null:
		sec_stripe.self_modulate = secondary_color
		sec_stripe.show()
	else:
		sec_stripe.hide()
