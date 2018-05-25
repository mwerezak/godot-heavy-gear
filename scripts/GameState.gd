extends Node

var root
onready var local_players = get_children()

func start_game(root):
	self.root = root
	root.context_panel.activate("activate_unit")

func activation_phase():
	pass

func get_all_players():
	return local_players