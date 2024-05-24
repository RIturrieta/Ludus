extends Node


var player_index = 1

@onready var timer = $Timer

func _ready():
	
	for test_player in Game.test_players:
		var player = Statics.PlayerData.new(
			1,
			test_player.name,
			test_player.role,
			test_player.character
		)
		Game.players.push_back(player)
	
	if Game.players.size() > 0:
		Game.players[0].id = 1
	
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_on_peer_connected)
	
	
	if not try_host():
		try_join()
	
	timer.timeout.connect(start_game)


func try_host() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(Statics.PORT, Statics.MAX_CLIENTS)
	if err == OK:
		multiplayer.multiplayer_peer = peer
	return err == OK


func try_join() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client("localhost", Statics.PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
	return err == OK


func _on_peer_connected(id: int) -> void:
	if is_multiplayer_authority():
		Game.players[player_index].id = id
		for i in Game.players.size():
			send_player_data_id.rpc(i, Game.players[i].id)
		player_index += 1


@rpc("reliable")
func send_player_data_id(playerDeindex, id):
	Game.players[player_index].id = id


func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
