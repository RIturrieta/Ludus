extends Ability

var players_on_area: Array
var casting: bool = false
var dmg_area: Area3D

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	dmg_area = $dmg_area
	preview = $dmg_area/preview
	preview.visible = false
	# delay = $dmg_area/delay
	# delay.timeout.connect(_on_delay_timeout)
	dmg_area.monitoring = true

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		preview.visible = true
		chara.can_act = false
		chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.clearRoots()
	chara.clearSlows()
	players_on_area = dmg_area.get_overlapping_bodies()
	for player in players_on_area:
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
