extends Reference

enum {
	LEVEL_HIDDEN = 0,
	LEVEL_UNIDENT,
	LEVEL_OBSERVED,
	LEVEL_FULL,
}

const INTEL_TYPES = {
	preload("res://scripts/units/Unit.gd"): "res://scripts/units/UnitIntel.gd",
	preload("res://scripts/structures/Structure.gd"): "res://scripts/structures/StructureIntel.gd",
}
const _TYPE_CACHE = {}

static func create_intel(object, intel_level = LEVEL_HIDDEN):
	var object_id = object.object_id
	var object_type = object.get_script()
	
	var path = INTEL_TYPES[object_type]
	if !_TYPE_CACHE.has(object_type):
		_TYPE_CACHE[object_type] = load(path)

	var intel = _TYPE_CACHE[object_type].new(object_id, object_type, intel_level)
	intel._data = intel._extract_data(object, intel_level)
	return intel

## Object Intel

var object_id
var object_type

var intel_level setget set_intel_level
var _data

func _init(object_id, object_type, intel_level = Level.HIDDEN):
	self.object_id = object_id
	self.object_type = object_type
	self.intel_level = intel_level

func set_intel_level(new_level):
	intel_level = new_level

func get_data():
	return _data

func apply_delta(delta):
	for key in delta:
		_data[key] = delta

func get_delta(new_data):
	var delta = {}
	for key in new_data:
		if _data[key] != new_data[key]:
			delta[key] = new_data[key]
	return delta

func get_update_delta(object, new_level = null):
	var new_data = _extract_data(object, new_level if new_level != null else intel_level)
	return get_delta(new_data)

func _get_func_instance():
	return get_script()

func _get_data_map():
	return {}

func _extract_data(object, intel_level):
	var data_map = _get_data_map()
	var instance = _get_func_instance()

	var data = {}
	for level in data_map:
		if level <= intel_level:
			var func_map = data_map[level]
			for key in func_map:
				data[key] = instance.call(func_map[key], object)

	return data