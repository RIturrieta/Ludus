extends Ability

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		
func execute():
	pass
	# [Insert the ability here]

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	on_cooldown = false
