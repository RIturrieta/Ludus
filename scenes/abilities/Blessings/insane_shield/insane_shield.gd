extends Ability

@export var armor_percentage: float = 75


func _ready():
	super()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		var cd_timer = cooldown_timers.get_child(charges - 1)
		cd_timer.start(cooldown - chara.cdr/100)
		charges -= 1
		chara.mana -= mana_cost
		chara.modifyStats(1, 1, 0, armor_percentage, armor_percentage)

func execute():
	pass

func endExecution():
	pass
