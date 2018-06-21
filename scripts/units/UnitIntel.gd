## represents what a side knows about a unit
## intermediates between units and GUI
extends Reference

enum Level {
	FULL,
	OBSERVED,
	UNIDENT,
	HIDDEN,
}

var unit_id
var intel_level

## all of these may be null to represent missing info
var owner_side
var faction
var name
var model_id
var position
var facing