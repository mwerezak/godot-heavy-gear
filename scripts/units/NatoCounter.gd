extends Sprite

export(String) var symbol = "unknown" setget set_symbol
export(Color) var primary_color = Color("#ffffff") setget set_primary_color
export(Color) var secondary_color = null setget set_secondary_color
export(Color) var symbol_foreground_color = Color("#000000") setget set_symbol_foreground_color
export(Color) var symbol_background_color = Color("#ffffff") setget set_symbol_background_color

onready var icon = $SymbolIcon
onready var stripe = $Stripe

func _ready():
	_update_icon()
	_update_stripe()

func set_primary_color(color):
	primary_color = color
	self_modulate = color

func set_secondary_color(color):
	secondary_color = color
	if stripe: _update_stripe()

func _update_stripe():
	if secondary_color != null:
		stripe.self_modulate = secondary_color
		stripe.show()
	else:
		stripe.hide()

func set_symbol(symbol_id):
	symbol = symbol_id
	if icon: _update_icon()

func set_symbol_foreground_color(color):
	symbol_foreground_color = color
	if icon: _update_icon()

func set_symbol_background_color(color):
	symbol_background_color = color
	if icon: _update_icon()

func _update_icon():
	icon.set_symbol(symbol)
	icon.set_foreground_color(symbol_foreground_color)
	icon.set_background_color(symbol_background_color)
