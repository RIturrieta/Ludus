extends Ability

func _ready():
	super()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		chara.abort_oneshots()
		on_cooldown = true
		cd_timer.start(cooldown - chara.cdr/100)
		chara.mana -= mana_cost
		execute()
		#chara.character_animations.set("parameters/WShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
func execute():
	chara.modifySpeed(1, 75)
	endExecution()

func endExecution():
	# [What happens after the execution of the ability]
	pass
