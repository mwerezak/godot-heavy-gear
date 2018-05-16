## Helpers for things like dice rolls, getting random items from arrays, etc.

extends Reference

static func get_random_idx(arr):
	return randi() % arr.size()

static func get_random_item(arr):
	return arr[randi() % arr.size()]
