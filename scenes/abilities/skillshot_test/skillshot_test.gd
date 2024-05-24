extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
var on_cooldown: bool = false
var projectile_ray: RayCast3D
var projectile_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

var projectile = load("res://scenes/abilities/skillshot_test/projectile.tscn")

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	projectile_ray = chara.projectile_ray
	projectile_spawn = chara.projectile_spawn
	p_forward = -projectile_ray.global_transform.basis.z.normalized()
	p_spawn_pos = projectile_spawn.global_position
	p_rotation = projectile_ray.rotation_degrees.y

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		execute()

func execute():
	p_forward = -projectile_ray.global_transform.basis.z.normalized()
	p_spawn_pos = projectile_spawn.global_position
	p_rotation = projectile_ray.rotation_degrees.y
	var p: RigidBody3D = projectile.instantiate()
	p.forward_dir = p_forward
	chara.add_sibling(p)
	p.global_position = p_spawn_pos

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	on_cooldown = false
	
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	pass
