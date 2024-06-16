extends Ability

func _ready():
	super()
	
func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()

func execute():
	# [Insert the ability here]
	pass

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	on_cooldown = false
