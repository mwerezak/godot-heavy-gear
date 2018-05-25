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
	return rotate_step(dir, TURN_180DEG)

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

const AXIAL_CONN = {
	0 : Vector2(1, 0),
	2 : Vector2(1, 1),
	4 : Vector2(0, 1),
	6 : Vector2(-1, 0),
	8 : Vector2(-1, -1),
	10: Vector2(0, -1),
}

## gets the step vector to adjacent grid positions for even and odd row hexes
const OFFSET_CONN_EVEN = {
	0 : Vector2(1, 0),
	2 : Vector2(0, 1),
	4 : Vector2(-1, 1),
	6 : Vector2(-1, 0),
	8 : Vector2(-1, -1),
	10: Vector2(0, -1),
}

const OFFSET_CONN_ODD = {
	0 : Vector2(1, 0),
	2 : Vector2(1, 1),
	4 : Vector2(0, 1),
	6 : Vector2(-1, 0),
	8 : Vector2(0, -1),
	10: Vector2(1, -1),
}

## map hex row parity to connection table
const OFFSET_CONN = {
	0 : OFFSET_CONN_EVEN,
	1 : OFFSET_CONN_ODD,
}

static func get_axial_step(cell_pos, dir):
	if !MOVE_DIRECTIONS.has(dir): 
		return cell_pos
	return cell_pos + AXIAL_CONN[dir]

static func get_axial_neighbors(cell_pos):
	var rval = AXIAL_CONN.duplicate()
	for dir in rval:
		rval[dir] += cell_pos
	return rval

static func get_offset_step(cell_pos, dir):
	if !MOVE_DIRECTIONS.has(dir): 
		return cell_pos
	
	var parity = int(cell_pos.y) & 1
	return cell_pos + OFFSET_CONN[parity][dir]

static func get_offset_neighbors(cell_pos):
	var parity = int(cell_pos.y) & 1
	var rval = {}
	
	for dir in MOVE_DIRECTIONS:
		rval[dir] = cell_pos + OFFSET_CONN[parity][dir]
	return rval

## produces a spiral path. radius is the number of rings, must be an integer
const _RADIAL_DIR = 0
const _STEP_DIRS = [4, 6, 8, 10, 0, 2]
static func get_spiral(radius):
	var cur_pos = Vector2(0,0)
	var path = [ cur_pos ]
	for ring in radius:
		cur_pos = get_axial_step(cur_pos, _RADIAL_DIR)
		for step_dir in _STEP_DIRS:
			for i in (ring + 1):
				path.push_back(cur_pos)
				cur_pos = get_axial_step(cur_pos, step_dir)
	return path

## note that rect positions MUST be absolute.
## Shift rect before calling this function, do not shift the results afterwards.
## returns cells in OFFSET coordinates
static func get_rect(rect):
	var contents = []
	var origin_parity = int(rect.position.y) & 1
	
	for r in range(rect.position.y, rect.end.y, sign(rect.size.y)):		
		var q_start = rect.position.x
		var q_end = rect.end.x
		
		var row_parity = int(r) & 1
		if row_parity != origin_parity:
			if origin_parity:
				q_end += 1
			else:
				q_start -= 1
		
		for q in range(q_start, q_end, sign(rect.size.x)):
			contents.push_back(Vector2(q, r))
	return contents
