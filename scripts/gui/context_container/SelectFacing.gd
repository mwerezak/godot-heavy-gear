extends "ContextBase.gd"

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")
const DirectionArc = preload("res://scripts/gui/DirectionArc.tscn")

const HELP_TEXT = "Select a location to rotate towards (or click on the unit to leave as is)."
const CONFIRM_TEXT = "Select a location to rotate towards (or again to confirm, or click on the unit to cancel)."

const MARKER_COLOR = Color(0.4, 0.9, 0.3)
const EXT_MARKER_COLOR = Color(0.9, 0.4, 0.3) #color for rotations that will take us into extended movement
const TARGET_MARKER_TEX = preload("res://icons/move_marker_32.png")

onready var turn_marker #shows available directions the unit can face
onready var ext_turn_marker
onready var target_marker #shows the location the unit is facing towards
onready var done_button = $MarginContainer/HBoxContainer/DoneButton
onready var label = $MarginContainer/HBoxContainer/Label
onready var action_icon = $MarginContainer/HBoxContainer/ActionIcon

var rotate_unit
var rotate_mode

var forced = false #if true, we set the unit's facing directly without spending any move actions

var allowed_dirs = {}
var facing_marker
var selected_dir

func _ready():
	action_icon.modulate = MARKER_COLOR
	
	var world_map = get_tree().get_root().find_node("WorldMap", true, false)
	
	target_marker = Sprite.new()
	target_marker.texture = TARGET_MARKER_TEX
	target_marker.modulate = MARKER_COLOR
	target_marker.z_as_relative = false
	target_marker.z_index = Constants.HUD_ZLAYER
	target_marker.hide()
	world_map.add_child(target_marker)
	
	turn_marker = DirectionArc.instance()
	turn_marker.modulate = MARKER_COLOR
	turn_marker.z_as_relative = false
	turn_marker.z_index = Constants.HUD_ZLAYER
	world_map.add_child(turn_marker)
	
	ext_turn_marker = DirectionArc.instance()
	ext_turn_marker.modulate = EXT_MARKER_COLOR
	ext_turn_marker.z_as_relative = false
	ext_turn_marker.z_index = Constants.HUD_ZLAYER
	world_map.add_child(ext_turn_marker)

func activated(args):
	label.text = HELP_TEXT
	
	rotate_unit = args.unit
	forced = args.forced if args.has("forced") else false
	.activated(args)
	
	var cur_activation = null
	
	if forced:
		## rotate any direction, for free
		for dir in range(HexUtils.DIR_WRAP):
			allowed_dirs[dir] = null
	else:
		var unit_info = rotate_unit.unit_info
		
		cur_activation = rotate_unit.current_activation
		rotate_mode = cur_activation.movement_mode if cur_activation.movement_mode else unit_info.get_default_rotation()
		
		allowed_dirs.clear()
		for dir in range(HexUtils.DIR_WRAP):
			if forced || rotate_mode.free_rotate:
				allowed_dirs[dir] = null
			else:
				var move_action_cost = cur_activation.get_rotation_cost(rotate_mode, dir).move_actions
				if move_action_cost <= cur_activation.move_actions:
					allowed_dirs[dir] = move_action_cost
	
	turn_marker.global_position = rotate_unit.map_marker.global_position
	turn_marker.clear()
	
	ext_turn_marker.global_position = rotate_unit.map_marker.global_position
	ext_turn_marker.clear()
	
	for dir in allowed_dirs:
		var move_action_cost = allowed_dirs[dir]
		if move_action_cost == null || cur_activation.move_actions - move_action_cost >= cur_activation.EXTENDED_MOVE:
			turn_marker.set_dir(dir, true)
		else:
			ext_turn_marker.set_dir(dir, true)

	selected_dir = rotate_unit.facing
	rotate_unit.map_marker.set_temp_facing(HexUtils.dir2rad(selected_dir))

	turn_marker.show()
	ext_turn_marker.show()

func resumed():
	.resumed()
	target_marker.show()

func deactivated():
	.deactivated()
	rotate_unit = null

func _become_active():
	._become_active()
	rotate_unit.map_marker.temp_facing_enabled = true

func _become_inactive():
	._become_inactive()
	turn_marker.hide()
	ext_turn_marker.hide()
	target_marker.hide()
	rotate_unit.map_marker.temp_facing_enabled = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		cancel_rotation()
	if selected_dir && (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select")):
		finalize_rotation()

func unit_cell_input(world_map, cell_pos, event):
	if event.is_action_pressed("click_select"):
		if cell_pos == rotate_unit.cell_position:
			if event.doubleclick:
				cancel_rotation() #allow double-clicking on unit to leave facing as is
		else:
			var dir = world_map.get_dir_to(rotate_unit.cell_position, cell_pos)
			
			if !allowed_dirs.has(dir):
				dir = _get_closest_dir(dir, allowed_dirs) ## get the closest allowed dir
			
			selected_dir = dir
			rotate_unit.map_marker.set_temp_facing(HexUtils.dir2rad(dir))
			label.text = CONFIRM_TEXT
			target_marker.position = world_map.get_grid_pos(cell_pos)
			target_marker.show()
			
			if event.doubleclick:
				finalize_rotation()

class ClosestDistanceMetric:
	var target_dir
	func _init(target_dir):
		self.target_dir = target_dir
	func get_metric(dir):
		return abs(HexUtils.get_shortest_turn(dir, target_dir))

func _get_closest_dir(dir, allowed_dirs):
	var metric = ClosestDistanceMetric.new(dir)
	var comparer = SortingUtils.MetricComparer.new(funcref(metric, "get_metric"))
	return SortingUtils.get_min_item(allowed_dirs.keys(), comparer, "compare")

func finalize_rotation():
	if forced:
		rotate_unit.set_facing(selected_dir)
	else:
		rotate_unit.current_activation.rotate(rotate_mode, selected_dir)
	context_manager.deactivate()

func cancel_rotation():
	context_manager.deactivate()

func _done_button_pressed():
	if selected_dir: finalize_rotation()

func _cancel_button_pressed():
	cancel_rotation()
