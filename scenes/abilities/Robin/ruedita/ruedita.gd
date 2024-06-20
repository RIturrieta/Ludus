extends DashAbility

@onready var area: Area3D = $area
@onready var area_collision: CollisionShape3D = $area/collision
@onready var delay_timer: Timer = $delay

func _ready():
	super()
	area_collision.shape.radius = chara.attack_range
	delay_timer.timeout.connect(dealDamage)
	
func _physics_process(delta):
	if not dashing:
		dashCalculation()

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.target_player = null
		chara.character_node.global_rotation.y = chara.projectile_ray.global_rotation.y
		chara.agent.navigation_layers = 0b00000010
		chara.character_animations.set("parameters/EShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	super()

func endExecution():
	super()
	delay_timer.start()

func dealDamage():
	chara.basic_attack.can_cancel = false
	chara.basic_attack.target_amount = 2 # This should be an Effect
	chara.basic_attack.beginExecution()
