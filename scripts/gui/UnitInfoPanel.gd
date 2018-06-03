extends PanelContainer

const NatoCounter = preload("res://scripts/units/NatoCounter.gd")

onready var container = $VBoxContainer
onready var symbol_icon = $VBoxContainer/HBoxContainer/SymbolIcon
onready var name_label = $VBoxContainer/HBoxContainer/NameLabel
onready var desc_label = $VBoxContainer/DescLabel

var pinned_object = null

func _ready():
	container.hide()

func select_units(units):
	if units.empty(): return
	
	#cycle to next unit (also allows showing info for stacked units)
	var pinned_idx = max(0, units.find(pinned_object))
	var next_idx = (pinned_idx + 1) % units.size()
	pinned_object = units[next_idx]
	show_unit_info(pinned_object)

func hover_units(units):
	if units.empty(): return
	if pinned_object == null || !units.has(pinned_object):
		pinned_object = null
		show_unit_info(units.front())

func clear_unit_info():
	container.hide()

func show_unit_info(unit):
	var unit_model = unit.unit_model
	var unit_desc = unit_model.desc
	var crew_info = unit.crew_info
	var rank_desc = crew_info.get_rank_desc()
	
	symbol_icon.texture = NatoCounter.SYMBOLS[unit_desc.symbol]
	
	name_label.text = "%s - %s" % [ unit_desc.name, unit_desc.short ]
	desc_label.text = "%s %s %s" %[rank_desc.short, crew_info.first_name, crew_info.last_name ]
	
	container.show()