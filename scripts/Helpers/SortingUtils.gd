## Helpers for sorting and searching


## returns true if left < right, false if left > right, and null otherwise
static func lexical_sort(sortv_left, sortv_right):
	var size = min(sortv_left.size(), sortv_right.size())
	for i in size:
		var left = sortv_left[i]
		var right = sortv_right[i]
		if left != right:
			return left < right
	return null

## a comparer that compares values based on the result of a function
class MetricComparer:
	var get_metric #FuncRef that converts a value into a ordinal
	
	func _init(get_metric):
		self.get_metric = get_metric
	
	func compare(left, right):
		return get_metric.call_func(left) < get_metric.call_func(right)

## a comparer that compares values based on a lexical sort
class LexicalComparer:
	var get_lexical #FuncRef that generates a lexical sort array
	
	func _init(get_lexical):
		self.get_lexical = get_lexical
	
	func compare(left, right):
		return lexical_sort(get_lexical.call_func(left), get_lexical.call_func(right))

## returns the 'minimum' item in arr based on the given sort function
static func get_min_item(arr, obj, sort_func):
	var min_item = null
	for item in arr:
		if min_item == null || obj.call(sort_func, item, min_item):
			min_item = item
	return min_item

static func get_max_item(arr, obj, sort_func):
	var max_item = null
	for item in arr:
		if max_item == null || obj.call(sort_func, max_item, item):
			max_item = item
	return max_item
