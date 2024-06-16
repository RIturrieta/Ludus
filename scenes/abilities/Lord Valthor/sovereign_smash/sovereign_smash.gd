extends Ability

@onready var dmg_area: Area3D = $dmg_area
@onready var delay: Timer = $dmg_area/delay
var players_on_area: Array
var casting: bool = false

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	delay.timeout.connect(_on_delay_timeout)
	preview = $dmg_area/preview
	preview.visible = false
	dmg_area.monitoring = true

func _physics_process(_delta):
	if not casting:
		dmg_area.global_rotation.y = chara.projectile_ray.global_rotation.y

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.target_player = null
		preview.visible = true
		casting = true
		chara.can_act = false
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	delay.start()
	
func _on_delay_timeout():
	players_on_area = dmg_area.get_overlapping_bodies()
	for player: BaseCharacter in players_on_area:
		if player.get_parent() != chara.get_parent():
			player.takeAbilityDamage(damage, chara.spell_power)
			if player.died():
				if chara.target_player:
					chara.target_player = null

func endExecution():
	casting = false
	players_on_area = []
	chara.can_act = true
	preview.visible = false

func _on_cd_timeout():
	on_cooldown = false
