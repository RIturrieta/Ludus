extends Ability

func _ready():
	super()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		for key in chara.abilities.keys():
			for timer: Timer in chara.abilities[key].cooldown_timers:
				if !timer.is_stopped():
					timer.stop()
			chara.abilities[key].charges = chara.abilities[key].total_charges
