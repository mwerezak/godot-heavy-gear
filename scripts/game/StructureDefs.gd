extends Node

const MovementModes = preload("res://scripts/game/MovementModes.gd")

const DEFAULT_STRUCTURE_TERRAIN = {
	impassable = [ MovementModes.WALKER, MovementModes.GROUND ], ## only infantry may enter buildings
}

const INFO = {
	industrial0 = {
		texture = preload("res://icons/structures/industrial0.png"),
		offset = Vector2(-29, 23), #from origin cell center to LL corner of sprite
		exclude_scatters = true, #if the structure prevents scatters from spawning on cells it occupies
		cell_footprint = [ Rect2(0, 0, 2, 2) ], #grid cells that this structure occupies
		
		## if not null, this structure overrides the terrain on the cells that it occupies
		## see TerrainDefs.gd. Any missing keys are inherited from the terrain the structure is on
		terrain_info = DEFAULT_STRUCTURE_TERRAIN,
	},
}

func get_info(structure_id):
	return INFO[structure_id]