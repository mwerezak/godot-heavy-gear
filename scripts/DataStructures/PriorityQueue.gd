extends Node

## Priority Queue implementation with binary heap
## Adapted from implementation courtesy of rileyphone
## Modified by mwerezak

var _value_heap
var _priority_heap

func _init():
	clear()

func clear():
	_priority_heap = [ 0 ]
	_value_heap = [ null ]

func add(value, priority):
	_value_heap.push_back(value)
	_priority_heap.push_back(priority)
	_perc_up(size())

func empty():
	return size() == 0 

func size():
	return _priority_heap.size() - 1

func pop_min():
	var retval = _value_heap[1]
	
	_value_heap[1] = _value_heap[size()]
	_priority_heap[1] = _priority_heap[size()]
	
	_priority_heap.pop_back()
	_value_heap.pop_back()
	
	_perc_down(1)
	return retval

func peek_min():
	return _value_heap[1]

func duplicate():
	var copy = new()
	copy._value_heap = _value_heap.duplicate()
	copy._priority_heap = _priority_heap.duplicate()
	return copy

func _swap(i, j):
	var tmp_priority = _priority_heap[i]
	var tmp_value = _value_heap[i]
	_priority_heap[i] = _priority_heap[j]
	_value_heap[i] = _value_heap[j]
	_priority_heap[j] = tmp_priority
	_value_heap[j] = tmp_value

func _perc_up(i):
	var pivot = floor(i / 2)
	while pivot > 0:
		if _priority_heap[i] < _priority_heap[pivot]:
			_swap(pivot, i)
		i = pivot
		pivot = floor(i / 2)

func _perc_down(i):
	while (i * 2) <= size():
		var mc = _min_child(i)
		if _priority_heap[i] > _priority_heap[mc]:
			_swap(i, mc)
		i = mc

func _min_child(i):
	if i * 2 + 1 > size():
		return i * 2
	
	if _priority_heap[i*2] < _priority_heap[i*2+1]:
		return i * 2
	
	return i * 2 + 1

