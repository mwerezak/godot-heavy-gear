extends Reference

enum IntelLevel {
	HIDDEN = 0,
	UNIDENT,
	OBSERVED,
	FULL,
}

## bitflag? e.g. sensor type
enum Contact {
	NONE = 0,
	OBSERVED = 1, #LOS (WIP)
	COMMAND = 2, #unit is owned by force and thus visible
}

var world_map

## tracks which units have contact with each other
var _tracked_objects = {}

## tracks any additional objects that each force is aware of, e.g. through command net
var _force_contacts = {}

func _init(world_map):
	self.world_map = world_map

func add_side(force_side):
	_force_contacts[force_side] = {}
	for unit in _tracked_objects:
		update_intel(force_side, unit)
	
func add_unit(new_unit):
	var old_units = _tracked_objects.keys()

	## create a new entry in the data structures
	_tracked_objects[new_unit] = {}

	## for now, every unit sees every other unit automatically
	for old_unit in old_units:
		set_contact_level(new_unit, old_unit, Contact.OBSERVED)
		set_contact_level(old_unit, new_unit, Contact.OBSERVED)

	## and all structures
	for struct in world_map.all_structures():
		set_contact_level(new_unit, struct, Contact.OBSERVED)

	## force has command contact with its units
	set_force_contact(new_unit.owner_side, new_unit, Contact.COMMAND)

func add_structure(struct):
	## for now, structures are always observed
	for unit in _tracked_objects:
		set_contact_level(unit, struct, Contact.OBSERVED)
	for force_side in _force_contacts:
		set_force_contact(force_side, struct, Contact.OBSERVED)

## Contact Level

func assign_contact_level(observer, observed, level):
	var old_level = get_contact_level(observer, observed)
	if level != old_level:
		_tracked_objects[observer][observed] = level
		update_intel_level(observer.owner_side, observed)

func set_contact_level(observer, observed, bitflag):
	var new_level = bitflag | get_contact_level(observer, observed)
	assign_contact_level(observer, observed, new_level)

func unset_contact_level(observer, observed, bitflag):
	var new_level = ~(bitflag) & get_contact_level(observer, observed)
	assign_contact_level(observer, observed, new_level)

func get_contact_level(observer, observed):
	if !_tracked_objects[observer].has(observed):
		return Contact.NONE
	return _tracked_objects[observer][observed]

## Force Contacts

func assign_force_contact(force_side, seen_object, level):
	var old_level = get_force_contact(force_side, seen_object)
	if level != old_level:
		_force_contacts[force_side][seen_object] = level
		update_intel_level(force_side, seen_object)

func set_force_contact(force_side, seen_object, bitflag):
	var new_level = bitflag | get_force_contact(force_side, seen_object)
	assign_force_contact(force_side, seen_object, new_level)

func unset_force_contact(force_side, seen_object, bitflag):
	var new_level = ~(bitflag) & get_force_contact(force_side, seen_object)
	assign_force_contact(force_side, seen_object, new_level)

func get_force_contact(force_side, seen_object):
	if !_force_contacts[force_side].has(seen_object):
		return Contact.NONE
	return _force_contacts[force_side][seen_object]

## Intel Level

func get_overall_contact(force_side, seen_object):
	var contact = get_force_contact(force_side, seen_object)
	for side_unit in force_side.owned_units:
		contact |= get_contact_level(side_unit, seen_object)
	return contact

func update_intel_level(force_side, seen_object):
	var contact_level = get_overall_contact(force_side, seen_object)

	var intel_level = IntelLevel.HIDDEN
	if contact_level & Contact.COMMAND:
		intel_level = IntelLevel.FULL
	elif contact_level > Contact.NONE:
		intel_level = IntelLevel.OBSERVED

	force_side.set_intel_level(seen_object, intel_level)
