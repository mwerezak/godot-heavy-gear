## A 2D marker that is used to show direction and facing arcs.

extends Node2D

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

onready var dir_marker0 = $Dir0
onready var direction_markers = [ dir_marker0 ]

func _ready():
	for dir in range(1, HexUtils.DIR_WRAP):
		var dir_marker = dir_marker0.duplicate(0)
		dir_marker.rotation = HexUtils.dir2rad(dir)
		add_child(dir_marker)
		direction_markers.push_back(dir_marker)
	clear()

## hides all direction markers
func clear():
	for marker in direction_markers: marker.hide()

func set_dir(dir, set):
	var marker = direction_markers[HexUtils.normalize(dir)]
	if set:
		marker.show()
	else:
		marker.hide()

## sets all markers from start_dir to end_dir, inclusive.
func set_arc(start_dir, end_dir, set):
	for dir in HexUtils.arc_dirs(start_dir, end_dir):
		var marker = direction_markers[dir]
		if set:
			marker.show()
		else:
			marker.hide()
