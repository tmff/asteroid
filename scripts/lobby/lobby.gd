extends Control

var connected_peers = []

var multiplayer_peer : ENetMultiplayerPeer

@onready var ip_input : TextEdit = $Menu/VBoxContainer/VBoxContainer/IP
@onready var port_input : SpinBox = $Menu/VBoxContainer/VBoxContainer/Port

var selected_character : int = 0

@export var main_scene : PackedScene

var selected_characters = {} #peer_id, int

var port

signal connected_to_server

var upnp : UPNP


func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_server.emit)

func _on_host_pressed():
	port = round(port_input.value)
	$Menu.hide()
	$GameLobby.show()
	#$GameLobby/VBoxContainer/Options/StartGame.show()
	setup_upnp()
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	connected_peers.append(1)
	multiplayer_peer.peer_connected.connect(handle_peer_connection)
	multiplayer_peer.peer_disconnected.connect(_on_player_disconnected)
	

func setup_upnp():
	upnp = UPNP.new()
	var result = upnp.discover()
	if result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			
			var map_result_udp = upnp.add_port_mapping(port,port,"godot_udp","UDP",0)
			var map_result_tcp = upnp.add_port_mapping(port,port,"godot_udp","TCP",0)
			
			
			if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(port,port,"","UDP")
			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(port,port,"","TCP")
	
	var external_address = upnp.query_external_address()
	print("Address is " + str(external_address))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if upnp != null:
			upnp.delete_port_mapping(port,"UDP")
			upnp.delete_port_mapping(port,"TCP")
			

func _on_client_pressed():
	$Menu.hide()
	$Connecting.show()
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer_peer.create_client(ip_input.text, round(port_input.value))
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer.server_disconnected.connect(_on_host_disconnected)
	connected_to_server.connect(show_client_lobby)
	
	
func show_client_lobby():
	$Connecting.hide()
	$GameLobby.show()
	$GameLobby/VBoxContainer/Start.hide()
	connected_to_server.disconnect(show_client_lobby)

func handle_peer_connection(peer_id):
	add_lobby_player(peer_id)
	add_previously_connected_players.rpc_id(peer_id,connected_peers)
	connected_peers.append(peer_id)
	
func add_lobby_player(_peer_id):
	pass
	#var players_container = $GameLobby/VBoxContainer/MainContainer/ScrollContainer/ConnectedPlayers
	#var lobby_player_inst = lobby_player_scene.instantiate()
	#lobby_player_inst.name = str(peer_id)
	#players_container.add_child(lobby_player_inst)
	#update_selected_character.rpc(peer_id,0)

func remove_lobby_player(_peer_id):
	pass
	
func reset_lobby_players():
	#var players_container = $GameLobby/VBoxContainer/MainContainer/ScrollContainer/ConnectedPlayers
	#for i in players_container.get_children():
	#	i.queue_free()
	pass

@rpc("any_peer","call_local")
func update_selected_character(id : int, character : int):
	selected_characters[id] = character
	
@rpc
func add_previously_connected_players(peer_ids):
	for id in peer_ids:
		add_lobby_player(id)
	pass

func _on_leave_pressed():
	multiplayer.multiplayer_peer = null
	
	connected_peers.clear()
	selected_characters.clear()
	reset_lobby_players()
	
	if upnp != null:
		upnp.delete_port_mapping(port,"UDP")
		upnp.delete_port_mapping(port,"TCP")
	
	$Connecting.hide()
	$GameLobby.hide()
	$Menu.show()

func load_main():
	load_main_rpc.rpc()

@rpc("call_local")
func load_main_rpc():
	$GameLobby.hide()
	var main = main_scene.instantiate()
	add_child(main,true)
	if multiplayer.is_server():
		await get_tree().create_timer(0.1).timeout
		main.host_load_match(connected_peers)


func _on_player_disconnected(id):
	connected_peers.erase(id)
	remove_lobby_player(id)
	
func _on_host_disconnected():
	multiplayer.multiplayer_peer = null
	
	connected_peers.clear()
	selected_characters.clear()
	reset_lobby_players()
	
	multiplayer.server_disconnected.disconnect(_on_host_disconnected)

	$GameLobby.hide()
	$Menu.show()
