## Helpers for things like dice rolls, getting random items from arrays, etc.

extends Reference

static func get_random_idx(arr):
	return randi() % arr.size()

static func get_random_item(arr):
	return arr[randi() % arr.size()]

static func get_weighted_random(dict):
	var items = dict.keys() #export keys to an array to ensure fixed order
	var weights = []
	
	var total_weight = 0
	for item in items:
		total_weight += dict[item]
		weights.push_back(total_weight)
	
	var roll = total_weight * randf()
	var idx = weights.bsearch(roll) #weights is sorted!
	return items[idx]

static func get_random_scatter(radius):
	var angle = deg2rad(360 * randf())
	var r = radius * randf()
	return r * Vector2(cos(angle), sin(angle))