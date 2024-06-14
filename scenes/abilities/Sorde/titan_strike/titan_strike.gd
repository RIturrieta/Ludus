extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview

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

var target_player: BaseCharacter

var jumping: bool = false

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
	chara.abort_oneshots()
	chara.agent.navigation_layers = 0b00000010
	on_cooldown = true
	cd_timer.start()
	chara.mana -= mana_cost
	chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.target_player = null
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = true
	jumping = true
	chara.dash(18 * 33.333)
	chara.updateTargetLocation(target_player.global_position)

func endExecution():
	jumping = false
	chara.clearDash()
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = false
	chara.agent.navigation_layers = 0b00000001
	target_player.takeAbilityDamage(damage, chara.spell_power)
	target_player.modifyStats(4, 1, 0, -25, 0, 1, 1, 0, 1)
	target_player = null

func _on_cd_timeout():
	on_cooldown = false
