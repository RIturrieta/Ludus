extends Ability

func _ready():
	super()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		chara.abort_oneshots()
		var cd_timer = cooldown_timers.get_child(charges-1)
		cd_timer.start(cooldown - chara.cdr/100)
		charges -= 1
		chara.mana -= mana_cost
		execute()
		#chara.character_animations.set("parameters/WShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
func execute():
	chara.modifySpeed(1, 75)
	endExecution()

func endExecution():
	# [What happens after the execution of the ability]
	pass
