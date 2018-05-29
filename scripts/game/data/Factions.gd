extends Node

## default ranks, used in unit type definitions
const ENLISTED = "enlisted"
const OFFICER = "officer"

const RANK_SPECIALIST = [ENLISTED, 2]
const RANK_SQUAD_LEAD = [ENLISTED, 4]
const RANK_SECTION_LEAD = [ENLISTED, 6]

const RANK_PLATOON_LEAD = [OFFICER, 1]
const RANK_COMPANY_LEAD = [OFFICER, 2]

var INFO = {
	north = {
		name = "North",
		short_name = "CNCS",
		full_name = "Confederated Northern City-States",
		adjective = "Northern",
		
		primary_color = Color("#aa7f2f"), 
		#secondary_color = Color("#2f5aaa"), 
		secondary_color = Color("#476192"), 
		
		namelists = {
			surnames = "res://namelists/north_surnames.txt",
			male = "res://namelists/north_male.txt",
			female = "res://namelists/north_female.txt",
		},
		
		ranks = {
			ENLISTED : {
				1: { full = "Private",  short = "Pvt" },
				2: { full = "Corporal", short = "Cpl" },
				3: { full = "Senior Corporal", short = "Sr Cpl" },
				4: { full = "Ranger", short = "Rngr" },
				5: { full = "Senior Ranger", short = "Sr Rngr" },
				6: { full = "Sergeant", short = "Sgt" },
				7: { full = "Senior Sergeant", short = "Sr Sgt" },
				8: { full = "Sergeant Major", short = "Sgt Maj" },
			},
			OFFICER : {
				1: { full = "Lieutenant",  short = "Lt" },
				2: { full = "Captain",  short = "Cpt" },
				3: { full = "Major",  short = "Maj" },
				4: { full = "Colonel",  short = "Col" },
				5: { full = "Brigadier",  short = "Brig" },
				6: { full = "General",  short = "Gen" },
			},
		},
		
		unit_models = [
			"dummy_gear",
			"dummy_vehicle",
			"dummy_infantry",
		],
	},
	south = {
		name = "South",
		short_name = "AST",
		full_name = "Allied Southern Territories",
		adjective = "Southern",
		
		primary_color = Color("#718888"), #Steel Blue
		secondary_color = Color("#b44545"), #Republic Red
		
		namelists = {
			surnames = "res://namelists/south_surnames.txt",
			male = "res://namelists/south_male.txt",
			female = "res://namelists/south_female.txt",
		},
		
		ranks = {
			ENLISTED : {
				1: { full = "Soldat",  short = "Sdt" },
				2: { full = "Sous-Caporal", short = "SCpl" },
				3: { full = "Caporal", short = "Cpl" },
				4: { full = "Sergent", short = "Sgt" },
				5: { full = "Sous-Adjudant", short = "SAdj" },
				6: { full = "Adjudant", short = "Adj" },
				7: { full = "Adjudant-Chef", short = "AdjC" },
				8: { full = "Major", short = "Maj" },
			},
			OFFICER : {
				1: { full = "Sous-Lieutenant",  short = "SLt" },
				2: { full = "Lieutenant",  short = "Lt" },
				3: { full = "Sous-Commandant",  short = "SCmdt" },
				4: { full = "Commandant",  short = "Cmdt" },
				5: { full = "Préfet",  short = "Pré" },
				6: { full = "Général",  short = "Gén" },
			},
		},
		
		unit_models = [
			"dummy_gear",
			"dummy_vehicle",
			"dummy_infantry",
		],
	},
}

func _init():
	for faction_id in INFO:
		var faction_info = INFO[faction_id]
		faction_info.faction_id = faction_id
		
		## load namelists
		var namelists = faction_info.namelists
		for key in namelists:
			namelists[key] = load_namelist(namelists[key])

func get_info(faction_id):
	return INFO[faction_id]

func all_factions():
	return INFO.keys()

## reads in a name list from file
static func load_namelist(path):
	var names = []
	var file = File.new()
	
	file.open(path, File.READ)
	while !file.eof_reached():
		var name = file.get_line().strip_edges()
		if !name.empty():
			names.push_back(name)
	file.close()
	
	return names
