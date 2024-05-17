extends CharacterBody2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.sprint("Player %s score %d" % [name, score])


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			var bullet = bullet_scene.instantiate()
			# spawner will spawn a bullet on every simulated
			multiplayer_spawner.add_child(bullet, true)
			# triggers syncronizer
			score += 1

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.sprint(message)
	Debug.sprint(sender_player.name)
