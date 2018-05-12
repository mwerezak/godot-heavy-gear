extends Node

## Priority Queue implementation with binary heap
## Implementation courtesy of rileyphone
## Modified by harpyeagle

var _heap
var _current_size

func _init():
	_heap = [[0]]
	_current_size = 0

func add(value, priority):
	_insert([priority, value])

func empty():
	return _current_size < 1

func size():
	return _current_size

func pop_min():
	var retval = _heap[1]
	_heap[1] = _heap[_current_size]
	_heap.remove(_current_size - 1)
	_current_size -= 1
	_perc_down(1)
	return retval[1]

func peek_min():
	return _heap[1][1]

func _insert(k):
	_heap.append(k)
	_current_size += 1
	_perc_up(_current_size)

func _perc_up(i):
	while floor(i / 2) > 0:
		if _heap[i][0] < _heap[floor(i / 2)][0]:
			var tmp = _heap[floor(i / 2)]
			_heap[floor(i / 2)] = _heap[i]
			_heap[i] = tmp
		i = floor(i / 2)

func _perc_down(i):
	while (i * 2) <= _current_size:
		var mc = _min_child(i)
		if _heap[i][0] > _heap[mc][0]:
		var tmp = _heap[i]
		_heap[i] = _heap[mc]
		_heap[mc] = tmp
		i = mc

func _min_child(i):
	if i * 2 + 1 > _current_size:
		return i * 2
	else:
		if _heap[i*2][0] < _heap[i*2+1][0]:
			return i * 2
		else:
			return i * 2 + 1

