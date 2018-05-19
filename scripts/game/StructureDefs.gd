extends Node

const MovementModes = preload("res://scripts/game/MovementModes.gd")
const TerrainDefs = preload("res://scripts/game/TerrainDefs.gd")

## only infantry may enter buildings, by default
const DEFAULT_BUILDING_TERRAIN = {
	impassable = [ MovementModes.WALKER, MovementModes.GROUND ],
	difficult = TerrainDefs.DEFAULT_DIFFICULT_TERRAIN,
}

## for structures that count as difficult terrain (which should be most non-building structures)
const DEFAULT_OBSTRUCTION_TERRAIN = {
	difficult = TerrainDefs.DEFAULT_DIFFICULT_TERRAIN,
}

const INFO = {
	industrial0 = {
		texture = preload("res://icons/structures/industrial0.png"),
		position_offset = Vector2(-29, 23), #offset POSITION in grid cell. Necessary to offset position so that YSort works correctly
		exclude_scatters = true, #if the structure prevents scatters from spawning on cells it occupies
		footprint = [ Rect2(0, 0, 2, -2) ], #grid cells that this structure occupies.
		
		height = 1.5, ## how tall is the structure?
		
		## if not null, this structure overrides the terrain on the cells that it occupies
		## see TerrainDefs.gd. Any missing keys are inherited from the terrain the structure is on
		terrain_info = DEFAULT_BUILDING_TERRAIN,
		stack_units = 1, #the number of units (typically infantry) that may occupy each cell of this structure
	},
	industrial1 = {
		texture = preload("res://icons/structures/industrial1.png"),
		position_offset = Vector2(-29, 23),
		exclude_scatters = true, 
		footprint = [ Rect2(0, 0, 2, -2) ], 
		
		height = 2.0,
		terrain_info = DEFAULT_BUILDING_TERRAIN,
		stack_units = 1,
	},
	highrise0 = {
		texture = preload("res://icons/structures/highrise0.png"),
		position_offset = Vector2(-25, 25), 
		exclude_scatters = true, 
		footprint = [ Rect2(0, 0, 1, 1) ], 
		
		terrain_info = DEFAULT_BUILDING_TERRAIN,
		stack_units = 3,
	},
	highrise1 = {
		texture = preload("res://icons/structures/highrise1.png"),
		position_offset = Vector2(-25, 25), 
		exclude_scatters = true, 
		footprint = [ Rect2(0, 0, 1, 1) ], 
		
		height = 3.0,
		terrain_info = DEFAULT_BUILDING_TERRAIN,
		stack_units = 2,
	},
	highrise2 = {
		texture = preload("res://icons/structures/highrise2.png"),
		position_offset = Vector2(-25, 25), 
		exclude_scatters = true, 
		footprint = [ Rect2(0, 0, 1, 1) ], 
		
		height = 4.0,
		terrain_info = DEFAULT_BUILDING_TERRAIN,
		stack_units = 2,
	},
}

func _init():
	for structure_id in INFO:
		INFO[structure_id].structure_id = structure_id

func get_info(structure_id):
	return INFO[structure_id]