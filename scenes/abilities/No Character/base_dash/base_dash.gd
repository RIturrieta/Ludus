extends DashAbility

func _ready():
	super()
	
func _physics_process(delta):
	if not dashing:
		dashCalculation()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		super()
		chara.target_player = null
		#chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	super()

func endExecution():
	super()
