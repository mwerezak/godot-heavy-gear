## Maps keys to arrays of values

extends Reference

var _map = {}

func push_back(key, value):
	var contents
	if !_map.has(key):
		_map[key] = [ value ]
	else:
		_map[key].push_back(value)

func remove(key, value):
	if _map.has(key):
		var contents = _map[key]
		var idx = contents.find(value)
		if idx >= 0: 
			contents.remove(idx)
			return true
	return false

func move(key, new_key, value):
	if remove(key, value):
		push_back(new_key, value)

func has_value(key, value):
	return _map.has(key) && _map[key].has(value)

func get_values(key):
	return _map[key]

## Dictionary API
func has(key):
	return _map.has(key)

func has_all(keys):
	return _map.has_all(keys)

func clear():
	_map.clear()

func duplicate():
	var copy = new()
	for key in _map:
		copy._map[key] = _map[key].duplicate()

func size():
	return _map.size()

func empty():
	return size() == 0

func hash():
	return _map.hash()

func keys():
	return _map.keys()
