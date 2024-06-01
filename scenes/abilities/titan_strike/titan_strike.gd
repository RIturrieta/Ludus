extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6

var range: float = 8

var on_cooldown: bool = false

var p_ray: RayCast3D
var p_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

var target_player

var jumping: bool = false
@onready var castime: Timer = $castime

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	p_ray = chara.projectile_ray
	p_spawn = chara.projectile_spawn
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y

func _physics_process(delta):
	if jumping:
		print(castime.time_left)
		var speed = chara.global_position.distance_to(target_player.global_position)/(castime.time_left + 0.1)
		print(speed)
		# var current_position = chara.global_position
		# var target_position = chara.agent.get_next_path_position()
		# var new_velocity = (target_position - current_position).normalized() * speed * 1000
		speed = speed * 15000 / (chara.SPEED * chara.move_speed)
		# print(new_velocity)
		print(chara.is_dashing)
		# chara.velocity = new_velocity
		chara.move_speed = speed
		chara.updateTargetLocation(target_player.global_position)

func beginExecution():
	if chara.is_multiplayer_authority():
		var mouse_pos = chara.screenPointToRay()
		if chara.is_target_player(mouse_pos):
			target_player = chara.get_target_player(mouse_pos)
			if chara.global_position.distance_to(target_player.global_position) < range:
				if target_player != chara and not on_cooldown and chara.mana >= mana_cost:
					#Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
					#on_cooldown = true
					#cd_timer.start()
					#chara.mana -= mana_cost
					beginExecutionRemote.rpc(target_player.player_info.id)

@rpc("any_peer", "call_local", "reliable")
func beginExecutionRemote(id: int):
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == id:
			target_player = player
			break
	Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	chara.agent.navigation_layers = 0b00000010
	chara.is_dashing = true
	on_cooldown = true
	cd_timer.start()
	chara.mana -= mana_cost
	chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.target_player = null
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = true
	print("xd")
	jumping = true
	castime.start()
	chara.updateTargetLocation(target_player.global_position)

func endExecution():
	jumping = false
	chara.is_dashing = false
	chara.move_speed = 100
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = false
	chara.agent.navigation_layers = 0b00000001
	target_player.hp -= (damage* (chara.spell_power / 100)) * (target_player.spell_armor / 100)
	Debug.sprint(target_player.get_parent().name + " recieved " + 
	String.num((damage*(chara.spell_power / 100)) * (target_player.spell_armor / 100)) + 
	" and now has " + String.num(target_player.hp) + " hp")
	target_player = null

func _on_cd_timeout():
	on_cooldown = false

# note: if the passive effect can affect the teammate, the character class will
# need a reference to their teammate
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	# [Insert the passive effect here]
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	# [Undo the passive effect here]
	pass
