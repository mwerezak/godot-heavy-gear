## returns a dictionary { rotate_unit, rotate_mode, selected_dir }, or null if cancelled

extends "ContextBase.gd"

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")
const SortingUtils = preload("res://scripts/helpers/SortingUtils.gd")
const DirectionArc = preload("res://scripts/gui/map/DirectionArc.tscn")

const HELP_TEXT = "Select a location to rotate towards (or click on the unit to leave as is)."
const CONFIRM_TEXT = "Select a location to rotate towards (or again to confirm, or click on the unit to cancel)."

onready var turn_marker = $AllowedDirs #shows available directions the unit can face
onready var ext_turn_marker = $ExtendedAllowedDirs
onready var target_marker = $TargetMarker
onready var done_button = $MarginContainer/HBoxContainer/DoneButton
onready var label = $MarginContainer/HBoxContainer/Label
onready var action_icon = $MarginContainer/HBoxContainer/ActionIcon

var unit_activation
var rotate_unit
var rotate_mode

var allowed_dirs
var facing_marker
var selected_dir

func _init():
	load_properties = {
		rotate_unit = REQUIRED,
		allowed_dirs = null
	}

func _ready():
	call_deferred("_ready_deferred")

func _ready_deferred():
	var world_map = get_tree().get_current_scene().world_map
	
	target_marker.z_as_relative = false
	target_marker.z_index = Constants.HUD_ZLAYER
	target_marker.hide()
	remove_child(target_marker)
	#world_map.add_child(target_marker)
	
	turn_marker.z_as_relative = false
	turn_marker.z_index = Constants.HUD_ZLAYER
	turn_marker.hide()
	remove_child(turn_marker)
	#world_map.add_child(turn_marker)
	
	ext_turn_marker.z_as_relative = false
	ext_turn_marker.z_index = Constants.HUD_ZLAYER
	ext_turn_marker.hide()
	remove_child(ext_turn_marker)
	#world_map.add_child(ext_turn_marker)

func _setup():
	label.text = HELP_TEXT

	if !allowed_dirs:
		## allow any direction
		allowed_dirs = {}
		for dir in range(HexUtils.DIR_WRAP):
			allowed_dirs[dir] = null

	"""
		var unit_model = rotate_unit.unit_model
		rotate_mode = unit_activation.current_move_mode() 
		if !rotate_mode:
			rotate_mode = unit_model.get_default_rotation()
		
		allowed_dirs.clear()
		for dir in range(HexUtils.DIR_WRAP):
			if rotate_mode.free_rotate:
				allowed_dirs[dir] = null
			else:
				#var move_action_cost = cur_activation.get_rotation_cost(rotate_mode, dir).move_actions
				#if move_action_cost <= cur_activation.move_actions:
				#	allowed_dirs[dir] = move_action_cost
				allowed_dirs[dir] = null ##TODO
	"""
	
	turn_marker.global_position = rotate_unit.map_marker.global_position
	turn_marker.clear()
	
	ext_turn_marker.global_position = rotate_unit.map_marker.global_position
	ext_turn_marker.clear()
	
	for dir in allowed_dirs:
		var move_action_cost = allowed_dirs[dir]
		if move_action_cost == null || unit_activation.move_actions - move_action_cost >= unit_activation.EXTENDED_MOVE:
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

func cell_input(world_map, grid_cell, event):
	if event.is_action_pressed("click_select"):
		if grid_cell == rotate_unit.cell_position:
			if event.doubleclick:
				cancel_rotation() #allow double-clicking on unit to leave facing as is
		else:
			var dir = world_map.unit_grid.get_axial_dir(rotate_unit.cell_position, grid_cell)
			
			if !allowed_dirs.has(dir):
				dir = _get_closest_dir(dir, allowed_dirs) ## get the closest allowed dir
			
			selected_dir = dir
			rotate_unit.map_marker.set_temp_facing(HexUtils.dir2rad(dir))
			label.text = CONFIRM_TEXT
			target_marker.position = world_map.unit_grid.axial_to_world(grid_cell)
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
	context_return({
		rotate_unit = rotate_unit,
		selected_dir = selected_dir,
	})

func cancel_rotation():
	context_return()

func _done_button_pressed():
	if selected_dir: finalize_rotation()

func _cancel_button_pressed():
	cancel_rotation()
