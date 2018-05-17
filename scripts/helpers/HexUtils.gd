extends Reference

##### LENGTH AND DISTANCE UNITS #####

const TERRAIN_SIZE = 256 ## edge-to-edge width of terrain hexes in pixels
const UNIT_DISTANCE = 32 ## length of a distance "unit" in pixels. 1 "unit" is equivalent to 1" in the HG:B ruleset, which uses 1:144 scale.

## conversion constants for distance "units" to real-world units. mostly for user output and display
const UNIT_FEET = 12
const UNIT_METRE = 3.6576

static func units2pixels(distance):
	return distance * UNIT_DISTANCE

static func pixels2units(pixels):
	return pixels/UNIT_DISTANCE

##### HEX GRID DIRECTION AND FACING #####

## Direction in 2D is measured in 30 degree steps.
## This way there are 12 discrete directions, one pointing at each hex corner and one at each hex face.
## Units can only move along hex edge directions, but we allow them to face corners for the purposes of
## Weapon arcs and also (more importantly) to make partial turns.

## Directions increase in the CW direction (like godot angles) and start at direction 0
## direction 0 points in the same direction as the (1,0) unit vector, to be compatible with Vector2.angle()
## Since the world map uses pointy-topped hexes, this means direction 0 points at the E hex edge.

const UNIT_ARC = deg2rad(30)
const DIR_MIN = 0
const DIR_MAX = 11
const DIR_WRAP = 12

## some constants for readability instead of magic numbers
const TURN_30DEG = 1
const TURN_60DEG = 2
const TURN_90DEG = 3
const TURN_120DEG = 4
const TURN_150DEG = 5
const TURN_180DEG = 6

static func normalize(dir):
	return wrapi(dir, DIR_MIN, DIR_WRAP)

static func nearest_dir(radians):
	var dir = round(radians/UNIT_ARC)
	return normalize(dir)

static func rotate_step(dir, rot):
	return normalize(dir + rot)

static func reverse_dir(dir):
	return rotate_step(dir, 6)

static func dir2rad(dir):
	return normalize(dir)*UNIT_ARC

## gets the magnitude and direction of the shortest turn starting at from_dir and ending at to_dir
## returns the number of rotate steps in the range of [-6, +6] for CCW and CW turns, respectively
static func get_shortest_turn(from_dir, to_dir):
	var diff = normalize(to_dir - from_dir + 6) - 6
	return diff + 12 if diff < -6 else diff

## returns an array of all dirs in the arc
static func arc_dirs(start_dir, end_dir):
	start_dir = normalize(start_dir)
	end_dir = normalize(end_dir)
	
	var arc = [ start_dir ]
	while start_dir != end_dir:
		start_dir = rotate_step(start_dir, 1)
		arc.push_back(start_dir)
	
	return arc

##### HEX GRID PATHING #####

## an array of all possible move directions
const MOVE_DIRECTIONS = [0, 2, 4, 6, 8, 10]

## gets the step vector to adjacent grid positions for even and odd row hexes
const HEX_CONN_EVEN = {
	0 : Vector2(1, 0),
	2 : Vector2(0, 1),
	4 : Vector2(-1, 1),
	6 : Vector2(-1, 0),
	8 : Vector2(-1, -1),
	10: Vector2(0, -1),
}

const HEX_CONN_ODD = {
	0 : Vector2(1, 0),
	2 : Vector2(1, 1),
	4 : Vector2(0, 1),
	6 : Vector2(-1, 0),
	8 : Vector2(0, -1),
	10: Vector2(1, -1),
}

## map hex row parity to connection table
const HEX_CONN = {
	0 : HEX_CONN_EVEN,
	1 : HEX_CONN_ODD,
}

static func get_step(cell_pos, dir):
	if !MOVE_DIRECTIONS.has(dir): 
		return cell_pos
	
	var parity = int(cell_pos.y) & 1
	return cell_pos + HEX_CONN[parity][dir]

static func get_neighbors(cell_pos):
	var parity = int(cell_pos.y) & 1
	var rval = {}
	
	for dir in MOVE_DIRECTIONS:
		rval[dir] = cell_pos + HEX_CONN[parity][dir]
	return rval

## Hex Geometry

## needed since the expression below can't be in a const for some reason
static func _get_cube_xform():
	return Transform2D(Vector2(1, 0), Vector2(0, 1).rotated(deg2rad(30)), Vector2(0,0))

## returns true if a point is inside a unit hex centered at the origin
static func inside_unit_hex(world_pos):
	var cube_pos = _get_cube_xform().xform_inv(world_pos)
	var z = -(cube_pos.x + cube_pos.y) #x + y + z = 0
	return abs(cube_pos.x) <= 1 && abs(cube_pos.y) <= 1 && abs(z) <= 1

static func inside_hex(hex_center, edge_radius, world_pos):
	return inside_unit_hex((world_pos - hex_center)/edge_radius)

## not sure if these are needed
static func cell2cube(cell_pos):
	var x = cell_pos.x - (cell_pos.y - (cell_pos.y&1))/2
	var z = cell_pos.y
	var y = -x-z
	return Vector3(x, y, z)

static func cube2cell(cube_pos):
	var col = cube_pos.x + (cube_pos.z - (cube_pos.z&1))/2
	var row = cube_pos.z
	return Vector2(col, row)

static func get_hex_vertices():
	return [
		Vector2(0, -1), Vector2(sqrt(3)/2, -0.5), Vector2(sqrt(3)/2, 0.5),
		Vector2(0, 1), Vector2(-sqrt(3)/2, 0.5), Vector2(-sqrt(3)/2, -0.5)
	]