extends Node

## someday all of this will be loaded from config files
var factions = preload("Factions.gd").new()
var terrain = preload("TerrainDefs.gd").new()
var structures = preload("StructureDefs.gd").new()
var units = preload("UnitDefs.gd").new()

## Factions
func all_faction_ids():
	return factions.all_factions()

func get_faction(faction_id):
	return factions.get_info(faction_id)

## Terrain Types
func get_terrain(terrain_id):
	return terrain.INFO[terrain_id]

func get_terrain_by_tile(tile_id):
	return terrain.get_terrain_info(tile_id)
	
func get_terrain_tileset():
	return terrain.tileset

## Structures
func get_structure_info(struct_id):
	return structures.get_info(struct_id)

## Unit Models
func get_unit_model(model_id):
	return units.get_model(model_id)

## Unit Symbols
func get_nato_icon(symbol_id):
	return units.NATO_SYMBOLS[symbol_id]