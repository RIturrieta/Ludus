extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $S1/preview
@onready var final_pos: MeshInstance3D = $S1/preview/final_pos

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
		preview.mesh.size.z = abs(target.position.z)
		preview.position.z = target.position.z/2
		final_pos.global_position = target.global_position
		if variable_dash_distance:
			var xd: float = s1.global_position.distance_to(chara.mouse_pos)
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
		target.global_position.y = 0

func beginExecution():
	if (not on_cooldown or cooldown <= 0.05) and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		chara.abort_oneshots()
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		chara.target_player = null
		chara.agent.navigation_layers = 0b00000010
		execute() # delete if there's an animation call

func execute():
	chara.updateTargetLocation(target.global_position)
	chara.global_position.x = target.global_position.x # use chara.dash() if the dash isn't instant
	chara.global_position.z = target.global_position.z
	endExecution() # delete if there's an animation call

func endExecution():
	chara.agent.navigation_layers = 0b00000001

func _on_cd_timeout():
	on_cooldown = false
