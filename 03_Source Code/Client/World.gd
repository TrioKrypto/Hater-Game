extends Spatial

onready var Player = load("res://Player.tscn")
var remainingTime = 300;
var treeMap;
var treeMapData;

puppet var hater_id;

puppet func spawn_player(spawn_pos, id, isHater):
	var player = Player.instance()
	
	player.translation = spawn_pos
	player.name = String(id) # Important
	player.set_network_master(id) # Important
	print("Player with id "+str(id)+" is Hater: "+str(isHater))
	player.isHater = isHater;
		
	$Players.add_child(player)
	
	print("Player spawned, ID: "+str(id))


puppet func remove_player(id):
	print("Player "+str(id)+" removed");
	#$Players.get_node(String(id)).queue_free()
	var player = $Players.get_node(String(id))
	$Players.remove_child(player)
	player.queue_free()


func _on_Timer_timeout():
	if(remainingTime>0):
		remainingTime -= 1;
		$CanvasLayer/RemainingTime.text = "%02d:%02d" % [(remainingTime/60),(remainingTime%60)]

