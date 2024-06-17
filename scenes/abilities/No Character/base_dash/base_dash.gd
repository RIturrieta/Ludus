extends DashAbility

func _ready():
	super()
	
func _physics_process(delta):
	if not dashing:
		dashCalculation()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.target_player = null
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.agent.navigation_layers = 0b00000010
		#chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		execute() # delete

func execute():
	chara.updateTargetLocation(target.global_position)
	chara.dash(350)
	dashing = true
	endExecution() # delete

func endExecution():
	super()
