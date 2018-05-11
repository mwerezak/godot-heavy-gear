extends Object

const TERRAIN_SIZE = 256 ## edge-to-edge width of terrain hexes in pixels
const UNIT_DISTANCE = 32 ## length of a distance "unit" in pixels. 1 unit is equivalent to 1" in the HG:B ruleset.

## conversion constants for distance "units" to real-world units. mostly for user output and display
const UNIT_FEET = 12
const UNIT_METRE = 3.6576

static func units_to_pixels(distance):
	return distance * UNIT_DISTANCE

static func pixels_to_units(pixels):
	return pixels/UNIT_DISTANCE
