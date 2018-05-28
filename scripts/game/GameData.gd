extends Node

var factions = preload("res://scripts/game/Factions.gd").new()
var terrain = preload("res://scripts/game/TerrainDefs.gd").new()
var structures = preload("res://scripts/game/StructureDefs.gd").new()
var unit_models = preload("res://scripts/game/UnitModels.gd").new()

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

## Structures
func get_structure_info(struct_id):
	return structures.get_info(struct_id)

## Unit Models
func get_unit_model(model_id):
	return unit_models.get_info(model_id)