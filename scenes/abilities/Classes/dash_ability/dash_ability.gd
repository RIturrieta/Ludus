extends Ability
class_name DashAbility

@onready var final_pos: MeshInstance3D = $S1/preview/final_pos

@export_category("Dash Stats")
@export var dash_distance: float = 0
@export var dash_speed: float = 350
@export var variable_dash_distance = false

# Dash calculation shapecasts
@onready var s1: ShapeCast3D = $S1
@onready var s2: ShapeCast3D = $S1/S2
@onready var target: Node3D = $S1/target
@onready var original_target: Node3D = $S1/original_target
var dashing: bool = false

func _ready():
	super()
	s1.target_position.z = -dash_distance
	s2.position.z = s1.target_position.z - 2
	target.position = s1.target_position
	original_target.position = s1.target_position
	
func dashCalculation():
	s1.rotation.y = chara.projectile_ray.rotation.y
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

func _physics_process(_delta):
	if not dashing:
		dashCalculation()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.agent.navigation_layers = 0b00000010
		#chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.updateTargetLocation(target.global_position)
	chara.dash(dash_speed)
	dashing = true

func endExecution():
	chara.clearDash()
	dashing = false
	chara.agent.navigation_layers = 0b00000001

func _on_cd_timeout():
	on_cooldown = false
