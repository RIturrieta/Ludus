extends Ability

func _ready():
	super()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		#chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	# [Insert the ability here]
	pass

func endExecution():
	# [What happens after the execution of the ability]
	chara.can_cast = true
