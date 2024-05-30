extends Node3D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: Array[PackedScene]
@onready var players: Node3D = $Players
@onready var arenas = $Arenas
var test_arena_scene = preload("res://scenes/levels/test_arena.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var start_timer: Timer = %StartTimer
@onready var top_text_label: Label = %TopTextLabel
var round_counter: float = 1
var start_remaining_time: int = 5
var started: bool = false

@onready var blessing_container: HBoxContainer = %BlessingContainer
var blessing_choice_array: Array[bool] = [false, false, false]

var local_player_id

func _ready() -> void:
	var test_arena = test_arena_scene.instantiate()
	arenas.add_child(test_arena)
	for player_data in Game.players:
		var player
		var test = 1 if Game.multiplayer_test else 0
		if player_data.character == (Statics.Character.CHAR1 - test):
			player = player_scene[0].instantiate()
		elif player_data.character == (Statics.Character.CHAR3 - test):
			player = player_scene[1].instantiate()
		
		var spawn_points = test_arena.get_node("SpawnPoints")
		for spawn_point in spawn_points.get_children():
			if (player_data.role == Statics.Role.TEAM_A and spawn_point.name == "TeamA1") \
			or (player_data.role == Statics.Role.TEAM_B and spawn_point.name == "TeamB1"):
				player.global_position = spawn_point.global_position
				break
		players.add_child(player, true)
		player.get_child(0).setup(player_data)
		player.get_child(0).defeated.connect(on_player_defeated)
		
		if player.get_child(0).is_multiplayer_authority():
			local_player_id = player.get_child(0).player_info.id
		# round_start_timer()
	if not Game.skip_start:
		start_blessing_choice()

func _physics_process(delta):
	if !started:
		if Game.skip_start:
			for player in players.get_children():
				player.get_child(0).can_act = true
			started = true
		else:
			var player_nodes = get_tree().get_nodes_in_group("players")
			var total = player_nodes.size()
			for player in player_nodes:
				if player.player_info.ready == true:
					total -= 1
			if total == 0:
				started = true
				round_start_timer()

func on_player_defeated(id: int):
	# Improve this function for custom announcments on kills
	# Like team eliminations or teammate defeated
	var player_nodes = get_tree().get_nodes_in_group("players")
	var total = player_nodes.size()
	var defeated_player
	for player in player_nodes:
		if player.hp <= 0:
			total -= 1
		if player.player_info.id == id:
			defeated_player = player
	# One player remains
	if total == 1:
		# If the defeated player has authority, it means the player died
		if defeated_player.is_multiplayer_authority():
			top_text_label.text = "Defeat"
		else:
			top_text_label.text = "Victory"
	else:
		top_text_label.text = defeated_player.get_parent().name
	animation_player.play("FadeOutSlow")

func start_blessing_choice():
	# Play animations
	# Display blessings choice window
	blessing_container.visible = true

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var choice = blessing_choice_array.find(true)
			if choice != -1:
				# Play animations
				# Add blessing to character
				blessing_container.visible = false
				set_player_ready.rpc(local_player_id)
				print(str("choice made: ", local_player_id, " is ready"))

@rpc("any_peer", "call_local", "reliable")
func set_player_ready(id: int):
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == id:
			player.player_info.ready = true

func round_start_timer():
	# blessing_container.visible = false
	if start_remaining_time == 0:
		start_remaining_time = 5
	start_timer.start()

func _on_start_timer_timeout():
	if start_remaining_time == 0:
		print("!!!!!!")
		start_timer.stop()
		top_text_label.text = "Fight!"
		animation_player.play("FadeOutSlow")
		for player in players.get_children():
			player.get_child(0).can_act = true
	else:
		top_text_label.text = str(start_remaining_time)
		start_remaining_time -= 1
		animation_player.play("FadeOut")


func _on_blessing_1_mouse_entered():
	blessing_choice_array[0] = true

func _on_blessing_1_mouse_exited():
	blessing_choice_array[0] = false

func _on_blessing_2_mouse_entered():
	blessing_choice_array[1] = true

func _on_blessing_2_mouse_exited():
	blessing_choice_array[1] = false

func _on_blessing_3_mouse_entered():
	blessing_choice_array[2] = true

func _on_blessing_3_mouse_exited():
	blessing_choice_array[2] = false
