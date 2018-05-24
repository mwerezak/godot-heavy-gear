extends Node

export(String) var display_name
export(int) var network_id setget set_network_id

func set_network_id(net_id):
	network_id = net_id
	name = str(net_id)
	set_network_master(net_id)