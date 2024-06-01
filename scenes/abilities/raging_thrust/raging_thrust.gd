extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export var dash_distance: float = 4
@export var variable_dash_distance = false

var on_cooldown: bool = false

var p_ray: RayCast3D
var p_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

# Dash calculation shapecasts
@onready var s1: ShapeCast3D = $S1
@onready var s2: ShapeCast3D = $S1/S2
@onready var target: Node3D = $S1/target
@onready var original_target: Node3D = $S1/original_target
@onready var impact_area: Area3D = $impact_area
var players_on_area: Array[Node3D] = []
var players_affected: Array[Node3D] = []

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	p_ray = chara.projectile_ray
	p_spawn = chara.projectile_spawn
	s1.target_position.z = -dash_distance
	s2.position.z = s1.target_position.z - 2
	target.position = s1.target_position
	original_target.position = s1.target_position
	

func _physics_process(delta):
	if not chara.is_dashing:
		s1.rotation = p_ray.rotation
		if variable_dash_distance:
			var xd: float = s1.global_position.distance_to(chara.screenPointToRay())
			if xd <= dash_distance:
				s1.target_position.z = -xd
			else:
				s1.target_position.z = -dash_distance
			s2.position.z = s1.target_position.z - 2
			original_target.position = s1.target_position
			target.position = s1.target_position
				
		if s1.is_colliding() and s2.is_colliding():
			var s2_unsafety = s2.get_closest_collision_unsafe_fraction()
			var s1_pos: Vector3 = s1.get_collision_point(0) + s1.get_collision_normal(0)/2
			if s2_unsafety != 1:
				var s2_pos: Vector3 = s2.get_collision_point(0) + s2.get_collision_normal(0)/2
				if s1_pos.distance_to(original_target.global_position) < s2_pos.distance_to(original_target.global_position):
					target.global_position = s1_pos
				else:
					target.global_position = s2_pos
			else:
				target.global_position = s1_pos
		else:
			target.position = s1.target_position
	else:
		players_on_area = impact_area.get_overlapping_bodies()
		for player in players_on_area:
			if not player in players_affected and player.get_parent() != chara.get_parent():
				players_affected.append(player)
				player.hp -= damage*chara.spell_power/100
				Debug.sprint(player.get_parent().name + " recieved " + 
				String.num(damage*chara.spell_power/100) + 
				" and now has " + String.num(player.hp) + " hp")

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		chara.agent.target_position = target.global_position
		chara.is_dashing = true
		chara.character_node.rotation.y = p_ray.rotation.y
		chara.agent.navigation_layers = 0b00000010
		chara.character_animations.set("parameters/EShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.target_player = null
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = true
	chara.updateTargetLocation(target.global_position)
	chara.move_speed = 800

func endExecution():
	chara.is_dashing = false
	chara.move_speed = 100
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = false
	chara.agent.navigation_layers = 0b00000001
	players_affected = []
	players_on_area = []

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
