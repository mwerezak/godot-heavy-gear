extends Node2D

export(String) var map_seed = "default"
export(Color) var global_lighting = Color("#ffffff")

export(Texture) var clouds_texture = preload("res://icons/terrain/scrolling_clouds.png")
export(Transform2D) var clouds_transform = Transform2D()

## a rectangle that describes the 'used' portion of the map, in tilemap coords (as seen when editing terrain tiles)
## note that the map corner is placed in the center of the corner hexes, so a half-hex margin is cut off each edge.
export(Rect2) var map_extents

