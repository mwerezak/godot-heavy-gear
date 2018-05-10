extends Node2D

const TERRAIN_ZLAYER = -1

onready var terrain = $TerrainTiles

func _ready():
	terrain.z_index = TERRAIN_ZLAYER