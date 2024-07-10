extends Ability

var players_on_area: Array
var casting: bool = false
var dmg_area: Area3D

func _ready():
	super()
	# delay = $dmg_area/delay
	# delay.timeout.connect(_on_delay_timeout)
	dmg_area = $dmg_area
	dmg_area.monitoring = true

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		preview.visible = true
		chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.clearRoots()
	chara.clearSlows()
	players_on_area = dmg_area.get_overlapping_bodies()
	for player in players_on_area:
		if player.team != chara.team:
			player.takeAbilityDamage(damage, chara.spell_power)

func endExecution():
	casting = false
	players_on_area = []
	preview.visible = false
	chara.can_cast = true
