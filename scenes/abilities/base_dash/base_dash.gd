extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export var dash_distance: float = 3
@export var variable_dash_distance = false

var on_cooldown: bool = false

var p_ray: RayCast3D
var p_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

# Dash calculation raycasts
@onready var r1: RayCast3D = $R1 # simulates the dash
@onready var r2: RayCast3D = $R1/R2 # detects collisions
@onready var r3: RayCast3D = $R1/R3 # backwards
@onready var r4: RayCast3D = $R1/R4 # forward
@onready var target = $R1/target

var dashing = false

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	p_ray = chara.projectile_ray
	p_spawn = chara.projectile_spawn
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y
	r1.target_position.z = -dash_distance
	r2.position.z = r1.target_position.z
	r3.position.z = r1.target_position.z - dash_distance
	r4.position.z = r1.target_position.z + dash_distance
	r3.target_position.z = dash_distance
	r4.target_position.z = -dash_distance
	target.position = r1.target_position
	

func _physics_process(delta):
	#if is_multiplayer_authority():
		#Debug.sprint(target.position)
	if not dashing:
		r1.rotation = p_ray.rotation
		if variable_dash_distance:
			var xd: float = r1.global_position.distance_to(chara.screenPointToRay())
			if xd <= dash_distance:
				r1.target_position.z = -xd
			else:
				r1.target_position.z = -dash_distance
			r2.position.z = r1.target_position.z
			r3.position.z = r1.target_position.z - dash_distance
			r4.position.z = r1.target_position.z + dash_distance
		
		if r2.is_colliding():
			var r2_p: Vector3 = r2.global_position
			var r3_p: Vector3 = r3.get_collision_point()
			var r4_p: Vector3 = r4.get_collision_point()
			if r2_p.distance_to(r3_p) < r2_p.distance_to(r4_p):
				target.global_position = r3_p
			else:
				target.global_position = r4_p
		else:
			target.position = r1.target_position
		
	else:
		chara.global_position.x = target.global_position.x
		chara.global_position.z = target.global_position.z
		endExecution()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		# [Insert animation call]
		execute() # delete if there's an animation call

func execute():
	dashing = true

func endExecution():
	dashing = false

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
