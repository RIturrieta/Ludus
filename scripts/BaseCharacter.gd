class_name BaseCharacter
extends CharacterBody3D

const SPEED = 4.5

var player_info: Statics.PlayerData = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var agent = $NavigationAgent3D
@onready var target: Vector3 = global_position

@onready var camera_3d = $Path3D/PathFollow3D/Camera3D
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path_3d = $Path3D

var camera_target_pos = 0.0
@onready var animation_player = $AllAnimationPlayer
# @onready var arrows = $PathArrows
@onready var arrows_transform = $ArrowsTransform

var locked_camera = true
@onready var camera_transform = $CameraTransform

@onready var label_3d = $Label3D

@export var character_node: Node3D
var character_animations: AnimationTree
@onready var character_animation_player: AnimationPlayer = character_node.find_child("AnimationPlayer")
@onready var prev_lookat = global_transform.basis.z
var prev_velocity = 0.0
# variables para ataque
var is_attacking = false
var target_player: BaseCharacter = null
var can_move = true

var can_rotate = true
var is_dashing = false
var is_silenced = false

# fixed movement variables
var fixed_movement = false
var fixed_direction: Vector3
var fixed_speed: float = 0

var camera_follow_speed = 0.6
# var screen_size: Vector2

var mouse_pos: Vector3
@onready var projectile_ray: RayCast3D = $ProjectileRay
@onready var projectile_spawn: Node3D = $ProjectileRay/SpawnPoint
@onready var projectile_spawn_pos: Vector3 = projectile_spawn.global_position
@onready var projectile_forward: Vector3 = -projectile_ray.global_transform.basis.z.normalized()

# ========== STATS ========== #
@export_category("Stats")
@export var hp: float = 1000
@export var mana: float = 100
@export var attack_damage: float = 100
@export var spell_power: float = 0
@export var physical_armor: float = 0
@export var spell_armor: float = 0
@export var move_speed: float = 100
@export var attack_speed: float = 1
@export var attack_range: float = 1
@export var cdr: float = 0
@export var select_radius: float = 3.0

var initial_attack_speed = attack_speed

# ========== HIDDEN STATS ========== #
var can_act: bool = false
var can_cast: bool = true
@export var total_attack_animations: int = 2
@export var attack_duration: float = 1
var basic_attack: Ability = null

signal defeated(character_id: int)


func _ready():
	updateTargetLocation(global_position)
	label_3d.global_transform = character_node.get_node("HealthMarker").global_transform
	character_animations = character_node.get_node("AnimationTree")
	for i in range(total_attack_animations):
		character_animations.set("parameters/AttackMul" + str(i + 1) + "/scale", attack_speed)
	
func _physics_process(delta):
	if can_act:
		if character_animations:
			var blend_val = min(velocity.length(), 1)
			var new_walk_vel = lerp(prev_velocity, float(blend_val), 0.5)
			prev_velocity = new_walk_vel
			character_animations.set("parameters/IdleWalkBlend/blend_amount", new_walk_vel)
			
		if target and can_rotate and is_multiplayer_authority():
			if (Vector3(global_transform.origin.x, 0.0, global_transform.origin.z) \
			- Vector3(target.x, 0.0, target.z)).length() > 0.5 and velocity.length() != 0:
				var new_look = lerp(prev_lookat, (global_transform.origin + velocity), 0.3)
				prev_lookat = new_look
				character_node.look_at(new_look, Vector3.UP)
				sendData.rpc(global_position, velocity, target, character_node.global_rotation.y)
				
		if is_multiplayer_authority():
			if Input.is_action_pressed("Move") and !is_dashing and can_move:
				target = screenPointToRay()
				if Input.is_action_just_pressed("Move"):
					target.y = 0.1
					arrows_transform.global_position = target
					animation_player.play("move_arrows")
				target.y = 0
				updateTargetLocation(target)

			if velocity.length() > 0.0:
				sendData.rpc(global_position, velocity, target, character_node.global_rotation.y)
			#if !agent.is_navigation_finished():
			# if position.distance_to(target) > 0.5:
			if !agent.is_navigation_finished() and (can_move or is_dashing):
				var current_position = global_transform.origin
				var target_position = agent.get_next_path_position()
				var new_velocity = (target_position - current_position).normalized() * SPEED * move_speed / 100
				velocity = new_velocity
			elif !agent.is_navigation_finished() and !can_move:
				agent.target_position = global_transform.origin
				updateTargetLocation(global_position)
			elif agent.is_navigation_finished():
				velocity = Vector3(0.0, 0.0, 0.0)
				global_position = lerp(global_position, agent.get_final_position(), 0.3)
				sendData.rpc(global_position, velocity, target, character_node.global_rotation.y)
			else:
				velocity = Vector3(0.0, 0.0, 0.0)
				sendData.rpc(global_position, velocity, target, character_node.global_rotation.y)
			
			mouse_pos = screenPointToRay()
			updateMousePos.rpc(mouse_pos)
		
		move_and_slide()
		manageSpeedModifiers()
	
	if is_multiplayer_authority():
		if can_cast and !is_silenced and !is_dashing:
			beginAbilityExecutions()
		if fixed_movement:
			velocity = Vector3(0,0,0)
			updateTargetLocation(global_position)
			if global_position.distance_to(fixed_direction) <= 1.5:
				global_position = lerp(global_position, fixed_direction, 0.3)
				updateTargetLocation(target)
				fixed_movement = false
				fixedMovement.rpc(fixed_direction, fixed_speed, fixed_movement)
			else:
				global_position = global_position.move_toward(fixed_direction, delta*fixed_speed)
				move_and_slide()
		sendData.rpc(global_position, velocity, target, character_node.global_rotation.y)
		
		## cooldowns debug
		#var pp = "|"
		#for key in abilities.keys():
			#if key in ["Q", "W", "E", "R"]:
				#pp += abilities[key][0] + ": " + str(snapped(abilities[key][1].cd_timer.time_left, 0.1)) + "| "
		#Debug.sprint(pp)
		
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

func updateTargetLocation(_target):
	agent.target_position = _target
	target = agent.get_final_position()
	
func moveCameraByCursor(_position: Vector2):
	if !locked_camera:
		var screen_size = get_viewport().get_visible_rect().size
		var screenX = screen_size.x
		var screenY = screen_size.y
		var dir = Vector2(0.0, 0.0)
		if screenX - _position.x < 11:
			dir += Vector2(camera_follow_speed, 0.0)
		elif _position.x < 11:
			dir += Vector2(-camera_follow_speed, 0.0)
		elif screenY - _position.y < 11:
			dir += Vector2(0.0, camera_follow_speed)
		elif _position.y < 11:
			dir += Vector2(0.0, -camera_follow_speed)
		path_3d.global_position += Vector3(dir.x, 0.0, dir.y)

# Moves the character to a certain point without using the navigation agent
@rpc("any_peer", "call_local")
func fixedMovement(direction: Vector3, speed: float, fixing: bool = true):
	updateTargetLocation(global_position)
	target_player = null
	fixed_direction = direction
	fixed_direction.y = 0
	fixed_speed = speed
	fixed_movement = fixing

func takeAttackDamage(damage: float):
	var total_damage = damage * (1 - physical_armor/100)
	if hp - total_damage <= 0:
		hp = 0
	else:
		hp -= total_damage
	Debug.sprint(get_parent().name + " recieved " + str(total_damage) + " and now has " + str(hp) + " hp")

func takeAbilityDamage(damage: float, attacker_spell_power: float):
	var total_damage = (damage * (1 + attacker_spell_power/100)) * (1 - spell_armor/100)
	if hp - total_damage <= 0:
		hp = 0
	else:
		hp -= total_damage
	Debug.sprint(get_parent().name + " recieved " + str(total_damage) + " and now has " + str(hp) + " hp")
	
func heal(points: float):
	#if hp + points <= hp_max:
	#	hp += points
	#else:
	#	hp = hp_max
	hp += points

# ========== ABILITIES ========== #

# Key: String | Value: String or Array[String, Node]
# An ability can be added by changing a null value for the name of the ability.
# When the ability is loaded, its value in the dictionary will change to an  
# array containing the name of the ability on [0] and it's node on [1].
@export_category("Abilities")
@export  var abilities: Dictionary = {
	"BA": "basic_attack",
	"Q": "",
	"W": "",
	"E": "",
	"R": "",
	"1": "",
	"2": "", 
	"3": "",
	"4": "",
}

# Adds the ability assigned to a certain key as a child of the character and puts
# it into the dictionary as an array that contains both the name and the node
func loadAbility(key: String):
	if abilities.has(key):
		if abilities[key] is String:
			var no_ability = false
			var path = "res://scenes/abilities/" + get_parent().name + "/" + abilities[key] + "/" + abilities[key] + ".tscn"
			if !ResourceLoader.exists(path):
				path = "res://scenes/abilities/" + "No Character" + "/" + abilities[key] + "/" + abilities[key] + ".tscn"
				if !ResourceLoader.exists(path):
					path = "res://scenes/abilities/No Character/base_ability/base_ability.tscn"
					no_ability = true
			var sceneNode = load(path).instantiate()
			sceneNode.set_multiplayer_authority(get_multiplayer_authority())
			if no_ability:
				abilities[key] = ["base_ability", sceneNode]
			else:
				abilities[key] = [abilities[key], sceneNode]
			$Abilities.add_child(sceneNode, true)
		
# Adds a new ability to the character and loads it
func addAbility(ability_name: String, key: String):
	if abilities[key] is Array:
		abilities[key][1].queue_free()
		abilities[key] = ability_name
		loadAbility(key)

# Executes abilities based on the input
func beginAbilityExecutions():
	for key in abilities.keys():
		if key != "BA":
			if Input.is_action_pressed("Shift") and is_multiplayer_authority():
				if Input.is_action_just_pressed(key):
					abilities[key][1].preview.visible = true
				if Input.is_action_just_released(key):
					beginRemoteExecution.rpc(key)
			elif Input.is_action_just_released("Shift") and is_multiplayer_authority():
				abilities[key][1].preview.visible = false
			else:
				if Input.is_action_just_pressed(key) and is_multiplayer_authority():
					beginRemoteExecution.rpc(key)

# Executes an ability. Used for animations
func executeAbility(_name):
	for array: Array in abilities.values():
		if array.has(_name):
			array[1].execute()
			break

# Marks the end of the execution of an ability. Used for animations
func endAbilityExecution(_name):
	for array: Array in abilities.values():
		if array.has(_name):
			array[1].endExecution()
			break

# RPC call to begin the cast of an ability
@rpc("call_local", "reliable")
func beginRemoteExecution(key):
	abilities[key][1].beginExecution()

# RPC call for updating the mouse position and the projectile raycast on remote
@rpc("call_local")
func updateMousePos(pos: Vector3):
	mouse_pos = pos
	projectile_ray.look_at(mouse_pos, Vector3.UP)
	projectile_ray.global_rotation.x = 0
	projectile_spawn_pos = projectile_spawn.global_position
	projectile_forward = -projectile_ray.global_transform.basis.z.normalized()

# ========== EFFECTS ========== #

func dash(amount: float):
	is_dashing = true
	var _dash = DashEffect.create(amount)
	$Effects.add_child(_dash)

func modifySpeed(duration: float, percentage: float):
	var _modifier = SpeedModifierEffect.create(duration, percentage)
	$Effects.add_child(_modifier)

func manageSpeedModifiers():
	var _dash: DashEffect = null
	for effect in $Effects.get_children():
		if effect is DashEffect:
			_dash = effect
			break
	var actual_slow: SpeedModifierEffect = null
	for effect in $Effects.get_children():
		if effect is SpeedModifierEffect:
			if effect.percentage < 0:     # slow
				if actual_slow == null:
					actual_slow = effect
				elif effect.percentage < actual_slow.percentage:
					if actual_slow.is_applied:
						actual_slow.unapply()
					actual_slow = effect
			else:                          # speed boost
				if _dash == null:
					if !effect.is_applied:
						effect.apply()
				elif effect.is_applied:
					effect.unapply()
	if actual_slow != null:
		if actual_slow.is_applied and _dash != null:
			actual_slow.unapply()
		elif !actual_slow.is_applied:
			actual_slow.apply()
	if _dash != null:
		_dash.apply()
	#if is_multiplayer_authority() and actual_slow != null:
		#Debug.sprint(actual_slow.multiplier)

func stun(duration: float):
	if $Effects.get_children().any(func (x): return x is StunEffect):
		for effect in $Effects.get_children():
			if effect is StunEffect:
				if duration > effect.timer.time_left:
					effect.stop()
					var _stun = StunEffect.create(duration)
					$Effects.add_child(_stun)
					break
	else:
		var _stun = StunEffect.create(duration)
		$Effects.add_child(_stun)

func root(duration: float):
	if $Effects.get_children().any(func (x): return x is RootEffect):
		for effect in $Effects.get_children():
			if effect is RootEffect:
				if duration > effect.timer.time_left:
					effect.stop()
					var _root = RootEffect.create(duration)
					$Effects.add_child(_root)
					break
	else:
		var _root = RootEffect.create(duration)
		$Effects.add_child(_root)

func silence(duration: float):
	if $Effects.get_children().any(func (x): return x is SilenceEffect):
		for effect in $Effects.get_children():
			if effect is SilenceEffect:
				if duration > effect.timer.time_left:
					effect.stop()
					var _silence = SilenceEffect.create(duration)
					$Effects.add_child(_silence)
					break
	else:
		var _silence = SilenceEffect.create(duration)
		$Effects.add_child(_silence)

func modifyStats(_duration: float, _attack_damage: float = 1, _spell_power: float = 0, 
								   _physical_armor: float = 0, _spell_armor: float = 0, 
								   _attack_speed: float = 1, _attack_range: float = 1,
								   _cdr: float = 0, _select_radius: float = 1):
									
	var modifier = StatsModifierEffect.create(_duration, _attack_damage, _spell_power, 
											  _physical_armor, _spell_armor, 
											  _attack_speed, _attack_range, 
											  _cdr, _select_radius)
	$Effects.add_child(modifier)

# Clear effects
func clearDash():
	for effect in $Effects.get_children():
		if effect is DashEffect:
			effect.unapply()
			effect.queue_free()
			is_dashing = false
			break

func clearStuns():
	for effect in $Effects.get_children():
		if effect is StunEffect:
			effect.stop()
			break

func clearRoots():
	for effect in $Effects.get_children():
		if effect is RootEffect:
			effect.stop()
			break

func clearSilences():
	for effect in $Effects.get_children():
		if effect is SilenceEffect:
			effect.stop()
			break

func clearSpeedModifier(duration: float, percentage: float):
	for effect in $Effects.get_children():
		if effect is SpeedModifierEffect:
			if effect.duration == duration and effect.percentage == percentage:
				effect.stop()
				break

func clearSlows():
	for effect in $Effects.get_children():
		if effect is SpeedModifierEffect:
			if effect.percentage < 0:
				effect.stop()
				break

func clearStatsModifier(_duration: float, _attack_damage: float = 1, _spell_power: float = 0, 
										  _physical_armor: float = 0, _spell_armor: float = 0, 
										  _attack_speed: float = 1, _attack_range: float = 1,
										  _cdr: float = 0, _select_radius: float = 1):
	for effect in $Effects.get_children():
		if effect is StatsModifierEffect:
			if (effect.duration == _duration and 
				effect.attack_damage == _attack_damage and effect.spell_power == _spell_power and
				effect.physical_armor == _physical_armor and effect.spell_armor == _spell_armor and
				effect.attack_speed == _attack_speed and effect.attack_range == _attack_range and
				effect.cdr == _cdr and effect.select_radius == _select_radius):
				effect.stop()
				break

func clearStatsModifiers():
	for effect in $Effects.get_children():
		if effect is StatsModifierEffect:
			effect.stop()


# ========== MULTIPLAYER ========== #

#funciones ataque
func is_target_player(_position: Vector3) -> bool:
	var target_players = get_tree().get_nodes_in_group("players")
	for player in target_players:
		var distance = _position.distance_to(player.global_transform.origin)
		if distance < player.select_radius && player.hp > 0:
			return true
	return false

# Returns character closest to mouse cursor
func get_target_player(_position: Vector3) -> CharacterBody3D:
	var target_players = get_tree().get_nodes_in_group("players")
	#target_players.erase(self)
	var players_in_range = []
	for player in target_players:
		var distance = _position.distance_to(player.global_transform.origin)
		if distance < player.select_radius and player.hp > 0:
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

#func attack_hit():
	#if is_multiplayer_authority():
		#if target_player:
			#can_move = false
			#attack_cooldown = attack_cooldown_offset
			#attack_animation_index = (attack_animation_index + 1) % total_attack_animations
			#attack_damage_remote.rpc(target_player.player_info.id)
#
#@rpc("call_local", "reliable")
#func attack_damage_remote(id: int):
	#var target_players = get_tree().get_nodes_in_group("players")
	#var _target_player: BaseCharacter
	#for player in target_players:
		#if player.player_info.id == id:
			#_target_player = player
			#break
	##for player in get_parent()
	#if _target_player:
		#_target_player.takeAttackDamage(attack_damage)
		#if _target_player.died():
			#if target_player:
				#target_player = null
#
#func start_attack_offset():
	#attack_cooldown_offset = attack_duration / attack_speed
#
#func start_attack():
	#is_attacking = true
	## can_move = false
	#attack_ended = false
	#target = global_position
	#character_node.look_at(target_player.global_position, Vector3.UP)
	#character_animations.set(str("parameters/BasicAttack", attack_animation_index + 1,"/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
#
#@rpc("call_remote", "reliable")
#func start_attack_remote(index: int):
	#character_animations.set(str("parameters/BasicAttack", index + 1,"/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
#
#@rpc("call_local", "reliable")
#func stop_attack():
	#is_attacking = false
	
func abort_oneshots():
	basic_attack.stopAttack()
	character_animations.set(str("parameters/QShot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	character_animations.set(str("parameters/QShot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	character_animations.set(str("parameters/WShot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	character_animations.set(str("parameters/EShot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	character_animations.set(str("parameters/R1Shot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	character_animations.set(str("parameters/R2Shot/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

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
	label_3d.text = str(player_info.name) + "\n" +str(get_parent().name)
	set_multiplayer_authority(player_info.id)
	if is_multiplayer_authority():
		camera_3d.current = true
	for key in abilities.keys():
		loadAbility(key)
	basic_attack = abilities["BA"][1]
	
@rpc
func sendData(pos: Vector3, vel: Vector3, _target: Vector3, rot_y: float):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	target = _target
	character_node.global_rotation.y = lerp_angle(character_node.global_rotation.y, rot_y, 0.75)
