extends Node2D

export(int) var map_seed = 0
export(TileSet) var terrain_tileset
export(Color) var global_lighting = Color(1,1,1)

## a rectangle that describes the 'used' portion of the map, in tilemap coords (as seen when editing terrain tiles)
## note that the map corner is placed in the center of the corner hexes, so a half-hex margin is cut off each edge.
export(Rect2) var map_extents

