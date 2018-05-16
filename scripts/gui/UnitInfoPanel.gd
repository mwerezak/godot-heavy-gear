extends PanelContainer

const NatoCounter = preload("res://scripts/units/NatoCounter.gd")

onready var container = $VBoxContainer
onready var name_label = $VBoxContainer/HBoxContainer/NameLabel
onready var symbol_icon = $VBoxContainer/HBoxContainer/SymbolIcon

var pinned_marker = null

func _ready():
	container.hide()

func select_markers(map_markers):
	var idx = max(0, map_markers.find(pinned_marker))
	
	#cycle to next unit (also allows showing info for stacked units)
	var next_idx = (idx + 1) % map_markers.size()
	pinned_marker = map_markers[next_idx]
	show_unit_info(pinned_marker)

func hover_markers(map_markers):
	if pinned_marker == null || !map_markers.has(pinned_marker):
		pinned_marker = null
		var map_marker = map_markers.front()
		show_unit_info(map_marker)

func clear_unit_info():
	container.hide()

func show_unit_info(map_marker):
	var unit = map_marker.get_parent()
	var unit_info = unit.unit_info
	
	name_label.text = unit.display_name
	symbol_icon.texture = NatoCounter.SYMBOLS[unit_info.get_symbol()]
	container.show()