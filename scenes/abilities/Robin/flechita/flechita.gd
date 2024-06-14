extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview
@onready var raycast: RayCast3D = $raycast
@onready var limit_mark: Marker3D = $raycast/limit_mark
var limit: Vector3

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export var radius: float = 7
var on_cooldown: bool = false
var p_ray: RayCast3D
var p_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

var p_scene = load("res://scenes/abilities/Robin/flechita/projectile.tscn")

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	p_ray = chara.projectile_ray
	p_spawn = chara.projectile_spawn
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y
	raycast.global_rotation = p_ray.global_rotation
	raycast.target_position = p_ray.target_position.normalized() * radius
	limit_mark.position = raycast.target_position
	limit_mark.global_position.y = p_spawn_pos.y
	limit = limit_mark.global_position

func _physics_process(delta):
	raycast.global_rotation = p_ray.global_rotation
	for projectile: Area3D in $projectiles.get_children():
		if projectile.global_position.distance_to(limit) < 0.1:
			projectile.queue_free()
		else:
			for body in projectile.get_overlapping_bodies():
				if body is BaseCharacter:
					body.takeAbilityDamage(damage, chara.spell_power)
				projectile.queue_free()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		chara.abort_oneshots()
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		p_rotation = p_ray.rotation_degrees.y
		chara.character_node.global_rotation_degrees.y = p_rotation
		chara.can_act = false
		chara.can_cast = false
		chara.updateTargetLocation(chara.global_position)
		chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y
	limit = limit_mark.global_position
	var p: Area3D = p_scene.instantiate()
	$projectiles.add_child(p)
	p.forward_dir = p_forward
	p.global_position = p_spawn_pos
	p.global_rotation_degrees.y = p_rotation

func endExecution():
	chara.can_act = true
	chara.can_cast = true
	preview.visible = false

func _on_cd_timeout():
	on_cooldown = false
