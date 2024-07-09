extends Ability

var healing: bool = false
var total_healing: float = 0
var heal_per_frame: float = 0
var og_hp: float

# 0.2s -> 3.9s  =>  3.7s duration

func _ready():
	super()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.character_animations.set("parameters/WShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	og_hp = chara.hp
	chara.modifyStats(3.7, 1, 0, 50, 50)
	total_healing = (chara.max_hp - chara.hp) * 0.5
	heal_per_frame = total_healing / (3.7 * 60)
	if is_multiplayer_authority():
		Debug.sprint(heal_per_frame)
	healing = true

func _physics_process(delta):
	if healing:
		chara.heal(heal_per_frame)
		if chara.velocity.length() > 0:
			chara.character_animations.set("parameters/WShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
			healing = false
			chara.can_cast = true
func endExecution():
	healing = false
	roundf(chara.hp)
	chara.can_cast = true
