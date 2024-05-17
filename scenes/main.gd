extends Node3D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@onready var players: Node3D = $Players
@onready var arenas = $Arenas
var test_arena_scene = preload("res://scenes/levels/test_arena.tscn")

func _ready() -> void:
	var test_arena = test_arena_scene.instantiate()
	arenas.add_child(test_arena)
	for player_data in Game.players:
		var player = player_scene.instantiate()
		
		print(player_data.name, player_data.role)
		
		var spawn_points = test_arena.get_child(-1)
		for spawn_point in spawn_points.get_children():
			if (player_data.role == Statics.Role.TEAM_A and spawn_point.name == "TeamA1") \
			or (player_data.role == Statics.Role.TEAM_B and spawn_point.name == "TeamB1"):
				player.global_position = spawn_point.global_position
				break
		players.add_child(player)
		player.get_child(0).setup(player_data)
