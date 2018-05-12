extends Node

## Priority Queue implementation with binary heap
## Implementation courtesy of rileyphone
## Modified by harpyeagle

var _heap

func _init(from_arr=null):
	_heap = [[0]]

func clear():
	_heap = [[0]]

func add(value, priority):
	_insert([priority, value])

func empty():
	return size() == 0 

func size():
	return _heap.size() - 1

func pop_min():
	var retval = _heap[1]
	_heap[1] = _heap[size()]
	_heap.pop_back()
	_perc_down(1)
	return retval[1]

func peek_min():
	return _heap[1][1]

func duplicate():
	var new_queue = new()
	for pair in _heap:
		new_queue.push_back(pair.duplicate())

func _insert(k):
	_heap.append(k)
	_perc_up(size())

func _perc_up(i):
	while floor(i / 2) > 0:
		if _heap[i][0] < _heap[floor(i / 2)][0]:
			var tmp = _heap[floor(i / 2)]
			_heap[floor(i / 2)] = _heap[i]
			_heap[i] = tmp
		i = floor(i / 2)

func _perc_down(i):
	while (i * 2) <= size():
		var mc = _min_child(i)
		if _heap[i][0] > _heap[mc][0]:
			var tmp = _heap[i]
			_heap[i] = _heap[mc]
			_heap[mc] = tmp
		i = mc

func _min_child(i):
	if i * 2 + 1 > size():
		return i * 2
	
	if _heap[i*2][0] < _heap[i*2+1][0]:
		return i * 2
	
	return i * 2 + 1

