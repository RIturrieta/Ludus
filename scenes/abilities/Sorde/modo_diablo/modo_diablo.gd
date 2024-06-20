extends Ability

func _ready():
	super()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.can_act = false
		chara.character_animations.set("parameters/R2Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.modifyStats(8, 1.2, 20, -20, -20, 1.25, 1, 0, 1)
	chara.modifySpeed(8, 10)
	$duration.start()

func endExecution():
	chara.can_act = true
	chara.can_cast = true

func _on_duration_timeout():
	var hair = chara.get_node("char3/Armature/Skeleton3D/Head/Hair")
	hair.visible = false
