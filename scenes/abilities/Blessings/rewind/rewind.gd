extends Ability

func _ready():
	super()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		for key in chara.abilities.keys():
			for timer: Timer in chara.abilities[key][1].cooldown_timers.get_children():
				if !timer.is_stopped():
					timer.stop()
			chara.abilities[key][1].charges = chara.abilities[key][1].total_charges
