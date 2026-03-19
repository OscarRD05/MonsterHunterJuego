extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var Player_scene : PackedScene
@rpc("any_peer","call_local")

func _on_join_pressed() -> void:
	peer.create_client("100.124.83.64",3500)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()
	
func _on_host_pressed() -> void:
	peer.create_server(3500, 2)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)

	add_player(multiplayer.get_unique_id()) 
	$CanvasLayer.hide()
func _ready():
	$MultiplayerSpawner.spawn_function = _spawn_player
	
func _spawn_player(id):
	var player = Player_scene.instantiate()
	player.name = str(id)
	return player
	
func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func add_player(id):
	var spawner = $MultiplayerSpawner
	spawner.spawn(id)

func del_player(id):
	rpc("_del_player",id)

func _del_player(id):
	get_node(str(id)).queue_free()
