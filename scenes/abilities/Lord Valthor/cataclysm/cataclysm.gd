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
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.abilities["BA"][1].target_player = null
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.can_rotate = false
		dashing = true
		chara.is_dashing = true
		chara.agent.navigation_layers = 0b00000010
		chara.character_animations.set("parameters/R2Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	super()
	dmg_timer.start()

func dealDamage():
	for i in range(s3.get_collision_count()):
		var player = s3.get_collider(i)
		if player.team != chara.team and not player in players_affected:
			players_affected.append(player)
			player.stun(3)
			if is_multiplayer_authority():
				player.takeAbilityDamage.rpc(damage, chara.spell_power)

func endExecution():
	chara.clearDash()
	dashing = false
	chara.can_rotate = true
	chara.agent.navigation_layers = 0b00000001
	players_affected = []
	players_on_area = []
	chara.can_cast = true
