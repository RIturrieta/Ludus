extends Ability

@onready var raycast: RayCast3D = $raycast
@onready var limit_mark: Marker3D = $raycast/limit_mark
var limit: Vector3
var affected_players: Array[BaseCharacter] = []

@export_category("Stats")
@export var radius: float = 7

var p_scene = load("res://scenes/abilities/Airi/ardeat/projectile.tscn")

func _ready():
	super()
	raycast.global_rotation = chara.projectile_ray.global_rotation
	raycast.target_position = chara.projectile_ray.target_position.normalized() * radius
	limit_mark.position = raycast.target_position
	limit_mark.global_position.y = chara.projectile_spawn_pos.y
	limit = limit_mark.global_position

func _physics_process(delta):
	raycast.global_rotation = chara.projectile_ray.global_rotation
	for projectile: Area3D in $projectiles.get_children():
		if projectile.global_position.distance_to(limit) < 0.1:
			projectile.returning = true
			affected_players = []
			projectile.forward_dir = chara.global_position
		else:
			if !projectile.returning:
				for player: BaseCharacter in projectile.get_overlapping_bodies():
					if player.team != chara.team and !(player in affected_players):
						player.takeAbilityDamage(damage, chara.spell_power)
						affected_players.append(player)
			else:
				projectile.forward_dir = chara.global_position
				for player: BaseCharacter in projectile.get_overlapping_bodies():
					if player == chara:
						affected_players = []
						projectile.queue_free()
					if player.team != chara.team and !(player in affected_players):
						player.takeAbilityDamage(damage, chara.spell_power)
						affected_players.append(player)

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.character_node.global_rotation.y = chara.projectile_ray.rotation.y
		chara.can_act = false
		chara.can_cast = false
		chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	var p: Area3D = p_scene.instantiate()
	$projectiles.add_child(p)
	p.forward_dir = limit_mark.global_position
	p.global_position = chara.projectile_spawn_pos
	p.global_rotation.y = chara.projectile_ray.global_rotation.y
	limit = limit_mark.global_position

func endExecution():
	chara.can_act = true
	chara.can_cast = true
	preview.visible = false
