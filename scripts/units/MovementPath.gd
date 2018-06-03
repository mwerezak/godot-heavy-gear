extends Reference

const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

var position = []
var facing = []

func _init(copy_from = null):
	if copy_from:
		position = copy_from.position.duplicate()
		facing = copy_from.facing.duplicate()

func last_pos():
	return position.back()

func last_facing():
	return facing.back()

func prev_facing():
	if !facing.empty():
		return facing[max(facing.size()-2, 0)]
	return null

func extend(next_pos, next_facing):
	position.push_back(next_pos)
	facing.push_back(next_facing)

func reverse_facing():
	for i in facing.size():
		facing[i] = HexUtils.reverse_dir(facing[i])