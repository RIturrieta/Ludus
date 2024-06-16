extends Ability

@onready var raycast: RayCast3D = $raycast
@onready var limit_mark: Marker3D = $raycast/limit_mark
var limit: Vector3

@export_category("Stats")
@export var radius: float = 7

var p_scene = load("res://scenes/abilities/Robin/flechita/projectile.tscn")

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	raycast.global_rotation = chara.projectile_ray.global_rotation
	raycast.target_position = chara.projectile_ray.target_position.normalized() * radius
	limit_mark.position = raycast.target_position
	limit_mark.global_position.y = chara.projectile_spawn_pos.y
	limit = limit_mark.global_position

func _physics_process(delta):
	raycast.global_rotation = chara.projectile_ray.global_rotation
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
		baseExecutionBegining()
		chara.character_node.global_rotation.y = chara.projectile_ray.rotation.y
		chara.can_act = false
		chara.can_cast = false
		chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	var p: Area3D = p_scene.instantiate()
	$projectiles.add_child(p)
	p.forward_dir = chara.projectile_forward
	p.global_position = chara.projectile_spawn_pos
	p.global_rotation.y = chara.projectile_ray.global_rotation.y
	limit = limit_mark.global_position

func endExecution():
	chara.can_act = true
	chara.can_cast = true
	preview.visible = false

func _on_cd_timeout():
	on_cooldown = false
