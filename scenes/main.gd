extends Node3D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: Array[PackedScene]
@onready var players: Node3D = $Players
@onready var arenas = $Arenas
var test_arena_scene = preload("res://scenes/levels/test_arena.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var start_timer: Timer = %StartTimer
@onready var next_round_timer: Timer = %NextRoundTimer
@onready var top_text_label: Label = %TopTextLabel
@onready var blessing1 = %Blessing1
@onready var blessing2 = %Blessing2
@onready var blessing3 = %Blessing3
@onready var ultimate1 = %Ultimate1
@onready var ultimate2 = %Ultimate2

var round_counter: float = 1
var start_remaining_time: int = 5
var started: bool = false
var next_indicator: int = 0

# First team to win 3 rounds wins the game, best out of 5 -> BRBBB
var rounds_to_win: int = 3
var team_A_wins: int = 0
var team_B_wins: int = 0
var local_player_team: Statics.Role

var local_blessing_count: int = 0

@onready var endgame_container: Control = %EndGameContainer
@onready var blessing_container: Control = %BlessingControl
@onready var hud: Control = %Hud
# @onready var blessing_container: HBoxContainer = %BlessingContainer
var blessing_choice_array: Array[bool] = [false, false, false]
var ultimate_choice_array: Array[bool] = [false, false]

var local_player_id


func _ready() -> void:
	var test_arena = test_arena_scene.instantiate()
	arenas.add_child(test_arena)
	for player_data in Game.players:
		var player
		var test = 1 if Game.multiplayer_test else 0
		if player_data.character == (Statics.Character.CHAR1 - test):
			player = player_scene[0].instantiate()
		elif player_data.character == (Statics.Character.CHAR2 - test):
			player = player_scene[1].instantiate()
		elif player_data.character == (Statics.Character.CHAR3 - test):
			player = player_scene[2].instantiate()
		elif player_data.character == (Statics.Character.CHAR4 - test):
			player = player_scene[3].instantiate()
		elif player_data.character == (Statics.Character.CHAR5 - test):
			player = player_scene[4].instantiate()
		
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
			local_player_team = player.get_child(0).player_info.role
		# round_start_timer()
	hud.prepare_icons()
	if not Game.skip_start:
		start_blessing_choice()

func _physics_process(_delta):
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
	var defeated_player
	for player in player_nodes:
		if player.player_info.id == id:
			defeated_player = player
			break
	var alive_from_team = 0
	for player in player_nodes:
		if player.player_info.role == defeated_player.player_info.role and player.hp > 0:
			alive_from_team += 1

	# One team remains
	if alive_from_team == 0:
		# If the defeated player has authority, it means the player died
		if defeated_player.player_info.role == local_player_team:
			top_text_label.text = "Defeat"
		else:
			top_text_label.text = "Victory"
		if defeated_player.player_info.role == Statics.Role.TEAM_A:
			#Debug.sprint("sumanding")
			team_B_wins += 1
		else:
			team_A_wins += 1
		next_indicator = 1
		if team_A_wins == rounds_to_win or team_B_wins == rounds_to_win:
			next_indicator = 2
		set_player_ready.rpc(local_player_id, false)
	else:
		top_text_label.text = defeated_player.get_parent().name + " was slain!"
	animation_player.play("FadeOutSlow")

func do_next():
	# Start next round
	print(team_A_wins, team_B_wins)
	var player_nodes = get_tree().get_nodes_in_group("players")
	if next_indicator == 1:
		next_indicator = 0
		started = false
		var test_arena = arenas.get_child(0)
		var spawn_points = test_arena.get_node("SpawnPoints")
		for player in player_nodes:
			for spawn_point in spawn_points.get_children():
				var player_data = player.player_info
				if (player_data.role == Statics.Role.TEAM_A and spawn_point.name == "TeamA1") \
				or (player_data.role == Statics.Role.TEAM_B and spawn_point.name == "TeamB1"):
					player.global_position = spawn_point.global_position
					player.reset()
					break
		if team_A_wins + team_B_wins == 1:
			start_ultimate_choice()
		elif not Game.skip_start:
			start_blessing_choice()
	if next_indicator == 2:
		for player in player_nodes:
			player.can_act = false
			var hitbox = player.get_node("HitBox")
			if hitbox:
				hitbox.disabled = true
			# Display return to main menu screen
			endgame_container.visible = true

func start_blessing_choice():
	# Play animations
	var path = "res://scenes/abilities/Blessings"
	# Iterate through blessings (sub directories) and choose 3 different at random
	var blessings = []
	var blessings_dir = DirAccess.open(path)
	if blessings_dir:
		blessings_dir.list_dir_begin()
		while true:
			var file = blessings_dir.get_next()
			if file == "":
				break
			if blessings_dir.current_is_dir():
				blessings.append(file)

	blessings.shuffle()
	# Give the name starting from the last / in the path
	blessing1.loadBlessing(blessings[0].split("/")[-1])
	blessing2.loadBlessing(blessings[1].split("/")[-1])
	blessing3.loadBlessing(blessings[2].split("/")[-1])
	# Display blessings choice window
	blessing_container.visible = true
	blessing1.visible = true
	blessing2.visible = true
	blessing3.visible = true
	ultimate1.visible = false
	ultimate2.visible = false

# This HAS to be changed later . . .
@export_category("Ultimates")
@export  var ultimates: Dictionary = {
	"Airi": ["congregatio", "radix"],
	"Bunkr": ["smash", "ballin"],
	"Lord Valthor": ["oblivion", "cataclysm"],
	"Robin": ["muchas_flechitas", "uwu"],
	"Sorde": ["titan_strike", "modo_diablo"],
}

func start_ultimate_choice():
	# Play animations
	var player_nodes = get_tree().get_nodes_in_group("players")
	var local_player
	for player in player_nodes:
		if player.player_info.id == local_player_id:
			local_player = player
			
	# Iterate through the character's abilities
	ultimate1.loadBlessing(ultimates[local_player.get_parent().name][0], local_player.get_parent().name)
	ultimate2.loadBlessing(ultimates[local_player.get_parent().name][1], local_player.get_parent().name)
	# Display blessings choice window
	blessing_container.visible = true
	blessing1.visible = false
	blessing2.visible = false
	blessing3.visible = false
	ultimate1.visible = true
	ultimate2.visible = true

func _input(event):
	if event is InputEventMouseButton:
		var choosing_blessing = false if team_A_wins + team_B_wins == 1 else true
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if choosing_blessing:
				var choice = blessing_choice_array.find(true)
				if choice != -1:
					# Play animations
					# Add blessing to character
					var blessings = [blessing1, blessing2, blessing3]
					var player_nodes = get_tree().get_nodes_in_group("players")
					for player in player_nodes:
						if player.player_info.id == local_player_id:
							add_blessing_to_player.rpc(local_player_id, blessings[choice].blessing_name)
					hud.prepare_blessing(local_blessing_count)
					local_blessing_count += 1
					blessing_container.visible = false
					set_player_ready.rpc(local_player_id, true)
					print(str("choice made: ", local_player_id, " is ready"))
			else:
				var choice = ultimate_choice_array.find(true)
				if choice != -1:
					# Play animations
					# Add blessing to character
					var player_nodes = get_tree().get_nodes_in_group("players")
					for player in player_nodes:
						if player.player_info.id == local_player_id:
							# Habilitar la ulti con id = choice, con rpc
							player.setUlt.rpc(choice+1)
					hud.prepare_icons(choice+1)
					blessing_container.visible = false
					set_player_ready.rpc(local_player_id, true)
					print(str("choice made: ", local_player_id, " is ready"))


@rpc("any_peer", "call_local", "reliable")
func add_blessing_to_player(id: int, bname: String):
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == id:
			player.addBlessing(bname)

@rpc("any_peer", "call_local", "reliable")
func set_player_ready(id: int, state: bool):
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == id:
			player.player_info.ready = state

func round_start_timer():
	# blessing_container.visible = false
	if start_remaining_time == 0:
		start_remaining_time = 5
	start_timer.start()

func _on_start_timer_timeout():
	if start_remaining_time == 0:
		print("!!!!!!")
		start_timer.stop()
		top_text_label.text = "Fight"
		animation_player.play("FadeOutSlow")
		for player in players.get_children():
			player.get_child(0).can_act = true
		set_player_ready.rpc(local_player_id, false)
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

func _on_next_round_timer_timeout():
	# acá se reviven los monos y se devuelven a su pos inicial
	pass

func _on_ultimate_1_mouse_entered():
	ultimate_choice_array[0] = true

func _on_ultimate_1_mouse_exited():
	ultimate_choice_array[0] = false

func _on_ultimate_2_mouse_entered():
	ultimate_choice_array[1] = true

func _on_ultimate_2_mouse_exited():
	ultimate_choice_array[1] = false


func _on_back_to_menu_pressed():
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_exit_pressed():
	multiplayer.multiplayer_peer.close()
	get_tree().quit()
