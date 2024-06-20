extends DashAbility
#5.5 270
@onready var s3: ShapeCast3D = $S3
var players_on_area: Array[Node3D] = []
var players_affected: Array[Node3D] = []

func _ready():
	super()
	s3.add_exception(chara)
	
func _physics_process(_delta):
	if not dashing:
		dashCalculation()
	else:
		for i in range(s3.get_collision_count()):
			var player = s3.get_collider(i)
			if player != chara and not player in players_affected:
				var normal = player.global_position - s3.get_collision_normal(i) * (6.5)
				normal.y = 0
				players_affected.append(player)
				player.stun(0.5)
				player.takeAbilityDamage(damage, chara.spell_power)
				if is_multiplayer_authority():
					player.fixedMovement.rpc(normal, 20)
				if player.died():
					if chara.target_player:
						chara.target_player = null

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.target_player = null
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.agent.navigation_layers = 0b00000010
		chara.collision_mask = 0b00000001
		chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	super()

func endExecution():
	super()
	chara.collision_mask = 0b00000011
	players_affected = []
	players_on_area = []
	
func _on_cd_timeout():
	on_cooldown = false
