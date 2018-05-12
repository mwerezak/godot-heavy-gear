## Direction in 2D is measured in 30 degree steps.
## This way there are 12 discrete directions, one pointing at each hex corner and one at each hex face.
## Units can only move along hex edge directions, but we allow them to face corners for the purposes of
## Weapon arcs and also (more importantly) to make partial turns.

## Directions increase in the CW direction (like godot angles) and start at direction 0
## direction 0 points in the same direction as the (1,0) unit vector, to be compatible with Vector2.angle()
## Since the world map uses pointy-topped hexes, this means direction 0 points at the E hex edge.

extends Node

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
