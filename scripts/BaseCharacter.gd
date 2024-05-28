class_name BaseCharacter
extends CharacterBody3D

const SPEED = 4.5
const JUMP_VELOCITY = 4.5

var player_info: Statics.PlayerData = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var agent = $NavigationAgent3D
var target: Vector3

@onready var camera_3d = $Path3D/PathFollow3D/Camera3D
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path_3d = $Path3D

var camera_target_pos = 0.0
@onready var animation_player = $AllAnimationPlayer
@onready var arrows = $PathArrows
@onready var arrows_transform = $ArrowsTransform

var locked_camera = true
@onready var camera_transform = $CameraTransform

@onready var label_3d = $Label3D

@export var character_node: Node3D
var character_animations: AnimationTree
var prev_lookat = global_transform.basis.z
var prev_velocity = 0.0
# variables para ataque
var is_attacking = false
var target_player: BaseCharacter = null
var can_move = true
var can_rotate = true
var is_dashing = false

var camera_follow_speed = 0.6
# var screen_size: Vector2

@onready var projectile_ray: RayCast3D = $ProjectileRay
@onready var projectile_spawn: Node3D = $ProjectileRay/SpawnPoint

# ========== STATS ========== #
@export_category("Stats")
@export var hp: float = 1000
@export var mana: float = 100
@export var attack_damage: float = 100
@export var spell_power: float = 100
@export var physical_armor: float = 100
@export var spell_armor: float = 100
@export var move_speed: float = 100
@export var attack_speed: float = 1
@export var attack_range: float = 1
@export var cdr: float = 0
@export var select_radius: float = 3.0

# ========== HIDDEN STATS ========== #
var can_act: bool = false
var attack_cooldown: float = 0
var attack_cooldown_offset: float = 0
var total_attack_animations: int = 2
var attack_animation_index: int = 0
var attack_ended: bool = true

signal defeated(character_id: int)


func _ready():
	label_3d.global_transform = character_node.get_node("HealthMarker").global_transform
	character_animations = character_node.get_node("AnimationTree")
	
	for key in abilities.keys():
		loadAbility(key)
	
func _physics_process(delta):
	if can_act:
		# Add the gravity.
		#if not is_on_floor():
		#	velocity.y -= gravity * delta
			
		if character_animations:
			var blend_val = min(velocity.length(), 1)
			var new_walk_vel = lerp(prev_velocity, float(blend_val), 0.5)
			prev_velocity = new_walk_vel
			character_animations.set("parameters/IdleWalkBlend/blend_amount", new_walk_vel)
			
		if target and can_rotate:
			if (Vector3(global_transform.origin.x, 0.0, global_transform.origin.z) \
			- Vector3(target.x, 0.0, target.z)).length() > 0.5 and velocity.length() != 0:
				var new_look = lerp(prev_lookat, (global_transform.origin + velocity), 0.3)
				prev_lookat = new_look
				character_node.look_at(new_look, Vector3.UP)
			#rotation.x = 0
			#rotation.y = 0
		#rotation.x = 0
		#rotation.y = 0
		if is_multiplayer_authority():
			# Lower basic attack cooldown
			attack_cooldown = max(0, attack_cooldown - delta)
			attack_cooldown_offset = max(0, attack_cooldown_offset - delta)
			if attack_cooldown == 0 && attack_cooldown_offset == 0 && !attack_ended:
				attack_ended = true
				# character_animations.set("parameters/Attack/blend_position", Vector2(attack_animation_index,0))
				# character_animations.set("parameters/AttackTransition/blend_position", Vector2(attack_animation_index,0))
			
			if Input.is_action_pressed("Move") and !is_dashing:
				target = screenPointToRay()
				if Input.is_action_just_pressed("Move"):
					target.y = 0.1
					arrows_transform.global_position = target
					animation_player.play("move_arrows")
				target.y = -0.5
				if can_move:
					updateTargetLocation(target)
				if is_target_player(target):
					target_player = get_target_player(target)
					if target_player == self:
						#target_player = null
						attack_cooldown_offset = 0
						# allow_movement()
					#start_attack(target_player)
					#if is_attacking:
						#updateTargetLocation(target)
						#if Input.is_action_just_pressed("Move"):
							#stop_attack()
				else:
					#stop_attack()
					target_player = null
					attack_cooldown_offset = 0
					# allow_movement()
			if target_player:
				if target_player != self:
					target = target_player.global_position
					if global_position.distance_to(target_player.global_position) <= attack_range:
						target = global_position
						if attack_ended:
							start_attack()
							start_attack_remote.rpc(attack_animation_index)
						else:
							stop_attack.rpc()
				updateTargetLocation(target)
			if velocity.length() > 0.0:
				sendData.rpc(global_position, velocity, target)
			#if !agent.is_navigation_finished():
			# if position.distance_to(target) > 0.5:
			if !agent.is_navigation_finished() and (can_move or is_dashing): #!!!!!
				var current_position = global_transform.origin
				var target_position = agent.get_next_path_position()
				var new_velocity = (target_position - current_position).normalized() * SPEED * move_speed / 100
				velocity = new_velocity
			elif !agent.is_navigation_finished() and !can_move: #!!!!
				agent.target_position = global_transform.origin
			else:
				velocity = Vector3(0.0, 0.0, 0.0)
				sendData.rpc(global_position, velocity, target)
		move_and_slide()
		
		if is_multiplayer_authority():
			var projectile_ray_target = screenPointToRay()
			projectile_ray.look_at(projectile_ray_target, Vector3(0,10,0))
			projectile_ray.global_rotation.x = 0
			updateProjectileRay.rpc(projectile_ray.global_rotation)
		beginAbilityExecutions()
	if Input.is_action_just_pressed("Release Camera"):
		if locked_camera:
			locked_camera = false
			path_3d.top_level = true
			camera_transform.update_position = false
			camera_transform.top_level = true
		else:
			locked_camera = true
			path_3d.top_level = false
			camera_transform.global_position = global_transform.origin
			camera_transform.update_position = true
			camera_transform.top_level = false
			
	if Input.is_action_pressed("Center Camera") and !locked_camera:
		print("Centering")
		locked_camera = true
		path_3d.top_level = false
		camera_transform.global_position = global_transform.origin
		camera_transform.update_position = true
		camera_transform.top_level = false
	
		locked_camera = false
		path_3d.top_level = true
		camera_transform.update_position = false
		camera_transform.top_level = true
	
	path_follow_3d.progress_ratio = lerp(path_follow_3d.progress_ratio, camera_target_pos, 0.2)

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			var ratio = path_follow_3d.progress_ratio
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and ratio < 1:
				camera_target_pos = min(ratio + 0.1, 1.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and ratio > 0:
				camera_target_pos = max(ratio - 0.1, 0.0)
			   # Mouse in viewport coordinates.
		elif event is InputEventMouseMotion:
			moveCameraByCursor(event.position)
	
func screenPointToRay():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera_3d.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera_3d.project_ray_normal(mouse_position) * 2000
	var args = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 0b00000001)
	var ray_array = space_state.intersect_ray(args)
	if ray_array.has("position"):
		return ray_array["position"]
	return Vector3()
	
func updateTargetLocation(target):
	agent.target_position = target
	
func moveCameraByCursor(position: Vector2):
	if !locked_camera:
		var screen_size = get_viewport().get_visible_rect().size
		var screenX = screen_size.x
		var screenY = screen_size.y
		var dir = Vector2(0.0, 0.0)
		if screenX - position.x < 11:
			dir += Vector2(camera_follow_speed, 0.0)
		elif position.x < 11:
			dir += Vector2(-camera_follow_speed, 0.0)
		elif screenY - position.y < 11:
			dir += Vector2(0.0, camera_follow_speed)
		elif position.y < 11:
			dir += Vector2(0.0, -camera_follow_speed)
		path_3d.global_position += Vector3(dir.x, 0.0, dir.y)


# ========== ABILITIES ========== #

# Key: String | Value: Node or String
# An ability can be added by changing a null value for the name of the ability.
# When the ability is loaded, its value in the dictionary will change to the 
# node of the ability instead of its name.
@export_category("Abilities")
@export  var abilities: Dictionary = {
	"Q": "garrotazo",
	"W": "skillshot_test",
	"E": "",
	"R": "shoulder_bash",
	"1": "",
	"2": "", 
	"3": "",
	"4": "",
}

# Adds the ability assigned to a certain key as a child of the character and
# adds the node to the dictionary
func loadAbility(key: String):
	if abilities.has(key):
		if type_string(typeof((abilities[key]))) == "String": 
			if abilities[key] == "":
				abilities[key] = "base_ability"
			var scene = load("res://scenes/abilities/" + abilities[key] + "/" + abilities[key] + ".tscn")
			var sceneNode = scene.instantiate()
			abilities[key] = sceneNode
			$Abilities.add_child(sceneNode, true)
			# print(Game.get_current_player().name + " " + get_parent().name + ": " + key)
		
# Adds a new ability to the character and loads it
func addAbility(ability_name: String, key: String):
	if type_string(typeof((abilities[key]))) != "String":
		abilities[key].queue_free()
	abilities[key] = ability_name
	loadAbility(key)

# Executes abilities based on the input
func beginAbilityExecutions():
	for key in abilities.keys():
		if Input.is_action_just_pressed(key) and is_multiplayer_authority():
			print(can_move)
			print(agent.target_position)
			beginRemoteExecution.rpc(key)

# Executes an ability. Used for animations
func executeAbility(key):
	abilities[key].execute()

# Marks the end of the execution of an ability. Used for animations
func endAbilityExecution(key):
	abilities[key].endExecution()

# RPC call to begin the cast of an ability
@rpc("call_local", "reliable")
func beginRemoteExecution(key):
	abilities[key].beginExecution()

# RPC call for updating the projectile raycast on remote	
@rpc
func updateProjectileRay(rotation):
	projectile_ray.global_rotation = rotation

# ========== MULTIPLAYER ========== #

#funciones ataque
func is_target_player(position: Vector3) -> bool:
	var target_players = get_tree().get_nodes_in_group("players")
	for player in target_players:
		var distance = position.distance_to(player.global_transform.origin)
		if distance < player.select_radius && player.hp > 0:
			return true
	return false

# Returns character closest to mouse cursor
func get_target_player(position: Vector3) -> CharacterBody3D:
	var target_players = get_tree().get_nodes_in_group("players")
	var players_in_range = []
	for player in target_players:
		var distance = position.distance_to(player.global_transform.origin)
		if distance < player.select_radius && player.hp > 0:
			players_in_range.append([player, distance])
	var closest_player = null
	var shortest_distance = 999999
	for pair in players_in_range:
		if pair[1] < shortest_distance:
			closest_player = pair[0]
			shortest_distance = pair[1]
	return closest_player

func allow_movement():
	can_move = true

func attack_hit():
	if is_multiplayer_authority():
		if target_player:
			can_move = false
			attack_cooldown = attack_cooldown_offset
			attack_animation_index = (attack_animation_index + 1) % total_attack_animations
			attack_damage_remote.rpc(target_player.player_info.id)

@rpc("call_local", "reliable")
func attack_damage_remote(id: int):
	var target_players = get_tree().get_nodes_in_group("players")
	var target
	for player in target_players:
		if player.player_info.id == id:
			target = player
			break
	#for player in get_parent()
	if target:
		target.hp -= attack_damage * (target.physical_armor / 100)
		Debug.sprint(target.get_parent().name + " recieved " + 
		String.num(attack_damage * (target.physical_armor / 100)) + 
		" and now has " + String.num(target.hp) + " hp")
		if target.died():
			if target_player:
				target_player = null

func start_attack_offset():
	attack_cooldown_offset = 1 / attack_speed

func start_attack():
	is_attacking = true
	# can_move = false
	attack_ended = false
	target = global_position
	character_animations.set(str("parameters/BasicAttack", attack_animation_index + 1,"/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

@rpc("call_remote", "reliable")
func start_attack_remote(index: int):
	character_animations.set(str("parameters/BasicAttack", index + 1,"/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

@rpc("call_local", "reliable")
func stop_attack():
	is_attacking = false 

func died():
	if hp <= 0:
		visible = false
		can_act = false
		var hitbox = get_node("HitBox")
		if hitbox:
			hitbox.disabled = true
		defeated.emit(player_info.id)
		return true
	return false

func setup(player_data: Statics.PlayerData):
	player_info = player_data
	name = str(player_info.id)
	label_3d.text = str(player_info.name) + "\nTeam" +str(player_info.role)
	set_multiplayer_authority(player_info.id)
	if is_multiplayer_authority():
		camera_3d.current = true
	
@rpc
func sendData(pos: Vector3, vel: Vector3, targ: Vector3):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	target = targ
