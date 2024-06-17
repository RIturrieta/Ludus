extends DashAbility

@onready var s3: ShapeCast3D = $S3
@onready var dmg_timer = $dmg_timer
var players_on_area: Array[Node3D] = []
var players_affected: Array[Node3D] = []

func _ready():
	super()
	s3.add_exception(chara)
	dmg_timer.timeout.connect(dealDamage)
	

func _physics_process(_delta):
	if not dashing:
		dashCalculation()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.target_player = null
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.agent.navigation_layers = 0b00000010
		chara.character_animations.set("parameters/R2Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.updateTargetLocation(target.global_position)
	chara.dash(250)
	dashing = true
	dmg_timer.start()

func dealDamage():
	for i in range(s3.get_collision_count()):
		var player = s3.get_collider(i)
		if player != chara and not player in players_affected:
			players_affected.append(player)
			player.stun(3)
			player.takeAbilityDamage(damage, chara.spell_power)
			if player.died():
				if chara.target_player:
					chara.target_player = null

func endExecution():
	chara.clearDash()
	dashing = false
	chara.agent.navigation_layers = 0b00000001
	players_affected = []
	players_on_area = []
	
func _on_cd_timeout():
	on_cooldown = false
