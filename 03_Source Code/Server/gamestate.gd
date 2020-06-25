extends Node

# Default game port
const DEFAULT_PORT = 44444
#https://gitlab.com/menip/godot-multiplayer-tutorials/-/blob/master/LobbylessTutorial/LobbylessTut.md
# Max number of players
const MAX_PLAYERS = 12

# Players dict stored as id:name
var players = {}
var ready_players = []

puppet var hater_id = null;

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	
	create_server()

func create_server():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(host)


# Callback from SceneTree, called when client connects
func _player_connected(_id):
	print("Client ", _id, " connected")


# Callback from SceneTree, called when client disconnects
func _player_disconnected(id):
	unregister_player(id)
	get_node("/root/World").remove_player(id)	
	
	#if ready_players.has(id):
	#	ready_players.erase(id)
	#	rpc("unregister_player", id)
	#
	#get_node("/root/World").remove_player(id)	
		
func reset():
	print("I should reset now...")
	#var world = load("res://World.tscn").instance()
	#get_tree().get_root().add_child(world)


# Player management functions
remote func register_player(new_player_name):
	# We get id this way instead of as parameter, to prevent users from pretending to be other users
	var caller_id = get_tree().get_rpc_sender_id()
	
	# If game is going, just ignore new guy
	if not has_node("/root/World"):
		# Add him to our list
		players[caller_id] = new_player_name
		
		# Add everyone to new player:
		for p_id in players:
			rpc_id(caller_id, "register_player", p_id, players[p_id]) # Send each player to new dude
		
		rpc("register_player", caller_id, players[caller_id]) # Send new dude to all players
		# NOTE: this means new player's register gets called twice, but fine as same info sent both times
		
		print("Client ", caller_id, " registered as ", new_player_name)


puppetsync func unregister_player(id):
	players.erase(id)
	print("Client ", id, " was unregistered")


remote func player_ready():
	var caller_id = get_tree().get_rpc_sender_id()
	
	if not ready_players.has(caller_id):
		ready_players.append(caller_id)
	
	if ready_players.size() == players.size():
		pre_start_game()


func pre_start_game():
	var world = load("res://World.tscn").instance()
	get_tree().get_root().add_child(world)
	
	var haterSet = false;
	# Spawn all the people
	for id in players:
		if(!haterSet):
			haterSet = true;
			get_node("/root/World").spawn_player(random_vector3(10,10, 10), id, true)
		else:
			get_node("/root/World").spawn_player(random_vector3(10,10, 10), id, false)
			
	rpc("pre_start_game")

	
remote func post_start_game():
	var caller_id = get_tree().get_rpc_sender_id()
	var world = get_node("/root/World")
	
	print(world.get_node("Players").get_children())
	hater_id = str(players.keys())[0];
	
	var haterSet = false;
	for player in world.get_node("Players").get_children():
		if(!haterSet):
			haterSet = true;
			player.isHater = true;
			world.rpc_id(caller_id, "spawn_player", player.position, player.get_network_master(), true)	
		else:
			world.rpc_id(caller_id, "spawn_player", player.position, player.get_network_master(), false)
			
	print("Setting hater_id to "+str(players.keys()[0]))

	
	#world.get_node("Players").get_children()[0].isHater = true
	#print(get_node("/root/World").get_node("Players").get_children()[0].isHater)
	#rpc("make_hater", players.keys()[0]) #send the id of the first player in the list to be the hater (random enough)
	
remote func update_hater_id(id):
	print(id)
	
# Return random 2D vector inside bounds 0, 0, bound_x, bound_y
func random_vector2(bound_x, bound_y):
	return Vector2(randf() * bound_x, randf() * bound_y)
	
func random_vector3(bound_x, bound_y, bound_z):
	return Vector3(randf() * bound_x, randf() * bound_y, randf() * bound_z)
