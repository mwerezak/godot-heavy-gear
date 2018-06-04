extends Sprite

export(String) var symbol = "infantry" setget set_symbol
export(Color) var primary_color = Color("#ffffff") setget set_primary_color
export(Color) var secondary_color = null setget set_secondary_color
export(Color) var symbol_foreground_color = Color("#000000") setget set_symbol_foreground_color
export(Color) var symbol_background_color = Color("#ffffff") setget set_symbol_background_color

onready var sym_sprite = $Symbol
onready var sym_back = $Symbol/Background
onready var sec_stripe = $Stripe

func set_symbol(symbol_id):
	symbol = symbol_id
	sym_sprite.texture = GameData.get_nato_icon(symbol_id)

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