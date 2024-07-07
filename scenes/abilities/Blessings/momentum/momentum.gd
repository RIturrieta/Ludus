extends Ability

@export var max_hp_percentage: float = 0
@export var spell_power_percentage: float = 0
@export var attack_damage_multiplier: float = 1


func _ready():
	super()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		var cd_timer = cooldown_timers.get_child(charges - 1)
		cd_timer.start(cooldown - chara.cdr/100)
		charges -= 1
		chara.mana -= mana_cost
		chara.modifyStats(4, 1, 0, 0, 0, 1, 1, 200, 1, 0, 0, 0)
		
