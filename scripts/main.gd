extends Node3D
class_name Main

@export var player_spawn_points : Array[Node3D]
@export var player_scene : PackedScene

var multiplayer_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var connected_peer_ids : Array = []

var player_characters : Dictionary = {}

func host_load_match(peer_ids : Array) -> void:
	add_players.rpc(peer_ids)
	pass
	
@rpc("call_local")
func add_players(peer_ids : Array):
	print("Adding players" + str(peer_ids.size()))
	connected_peer_ids = peer_ids
	var count = 0
	for i in peer_ids:
		add_player_character(i, count)
		count += 1
		if count >= player_spawn_points.size():
			count = 0


func add_player_character(peer_id : int, index : int) -> void:
	var player_inst = player_scene.instantiate()
	player_inst.name = str(peer_id)
	player_inst.set_multiplayer_authority(peer_id)
	player_inst.position = player_spawn_points[index].global_position
	player_characters[peer_id] = player_inst
	add_child(player_inst,true)
