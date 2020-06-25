extends Spatial

onready var Player = load("res://Player.tscn")

func spawn_player(spawn_pos, id, isHater):
	var player = Player.instance()
	
	player.position = spawn_pos
	player.name = String(id) # Important
	player.set_network_master(id) # Important
	player.isHater = isHater;
	
	$Players.add_child(player)


#remotesync func remove_player(id):
#	$Players.get_node(String(id)).queue_free()

func remove_player(id):
	var player = $Players.get_node(String(id))
	$Players.remove_child(player)
	rpc("remove_player", id)
	player.queue_free()
