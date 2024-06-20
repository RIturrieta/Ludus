extends DashAbility

@onready var impact_area: Area3D = $impact_area
var players_on_area: Array[Node3D] = []
var players_affected: Array[Node3D] = []

func _ready():
	super()

func _physics_process(_delta):
	if not dashing:
		dashCalculation()
	else:
		players_on_area = impact_area.get_overlapping_bodies()
		for player in players_on_area:
			if not player in players_affected and player.get_parent() != chara.get_parent():
				players_affected.append(player)
				player.takeAbilityDamage(damage, chara.spell_power)

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.target_player = null
		chara.character_node.rotation.y = chara.projectile_ray.rotation.y
		chara.agent.navigation_layers = 0b00000010
		chara.character_animations.set("parameters/EShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = true
	super()

func endExecution():
	super()
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = false
	players_affected = []
	players_on_area = []

func _on_cd_timeout():
	on_cooldown = false
