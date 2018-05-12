extends Node

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

static func normalize(dir):
	return wrapi(dir, DIR_MIN, DIR_WRAP)

static func nearest_dir(radians):
	var dir = round(radians/UNIT_ARC)
	return normalize(dir)

static func rotate_step(dir, rot):
	return normalize(dir + rot)

static func dir2rad(dir):
	return normalize(dir)*UNIT_ARC

## gets the magnitude and direction of the shortest turn starting at from_dir and ending at to_dir
## returns the number of rotate steps in the range of [-6, +6] for CCW and CW turns, respectively
static func get_shortest_turn(from_dir, to_dir):
	var diff = normalize(to_dir - from_dir + 6) - 6
	return diff + 12 if diff < -6 else diff

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

