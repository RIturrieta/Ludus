extends DashAbility

func _ready():
	super()

func _physics_process(delta):
	if not chara.is_dashing:
		dashCalculation()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.agent.navigation_layers = 0b00000010
		execute() # delete if there's an animation call

func execute():
	chara.updateTargetLocation(target.global_position)
	chara.global_position.x = target.global_position.x
	chara.global_position.z = target.global_position.z
	endExecution() # delete if there's an animation call

func endExecution():
	chara.agent.navigation_layers = 0b00000001
