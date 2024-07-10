extends Ability

@onready var raycast: RayCast3D = $raycast
@onready var limit_mark: Marker3D = $raycast/limit_mark
var limit: Vector3

@export_category("Stats")
@export var radius: float = 7
@export var root_radius: float = 6

var affected_player: BaseCharacter = null

var p_scene = load("res://scenes/abilities/Airi/radix/projectile.tscn")

func _ready():
	super()
	preview.mesh.top_radius = root_radius
	preview.mesh.bottom_radius = root_radius
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
					if body.team != chara.team:
						affected_player = body
						projectile.queue_free()
						break
				projectile.queue_free()
		if affected_player != null:
			preview.global_position = affected_player.global_position
			preview.visible = true
			var target_players = get_tree().get_nodes_in_group("players")
			for player: BaseCharacter in target_players:
				if player.team != chara.team:
					if player.global_position.distance_to(affected_player.global_position) <= root_radius:
						player.root(5)
						Debug.sprint(player.get_parent().name + " was rooted!")
			affected_player = null
		

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.character_node.global_rotation.y = chara.projectile_ray.rotation.y
		chara.can_act = false
		chara.can_cast = false
		chara.character_animations.set("parameters/R2Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

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
