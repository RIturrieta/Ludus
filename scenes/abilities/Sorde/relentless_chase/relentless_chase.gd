extends Ability

@export_category("Stats")
@export var duration: float = 3
@onready var duration_timer: Timer = $duration
var chara_animations: AnimationTree
var chasing: bool = false
var index

func _ready():
	super()
	duration_timer.timeout.connect(_on_duration_timeout)
	duration_timer.wait_time = duration

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		index = chara.basic_attack.current_attack_index
		chara.total_attack_animations = 3
		chara.basic_attack.current_attack_index = 2
		chara.character_animations.set("parameters/WWalkBlend/blend_amount", 1)
		chara.modifySpeed(duration, 100)
		chara.modifyStats(duration, 1.75)
		duration_timer.start()
		chasing = true

func execute():
	chasing = false
	var target_player = chara.get_target_player(chara.target)
	if target_player != null:
		target_player.modifySpeed(2, -30)
	chara.total_attack_animations = 2
	chara.basic_attack.current_attack_index = index

func endExecution():
	chara.clearStatsModifier(duration, 1.75)
	chara.clearSpeedModifier(duration, 100)
	chara.character_animations.set("parameters/WWalkBlend/blend_amount", 0)
	chara.can_cast = true
	#chara.total_attack_animations = 2
	#chara.attack_animation_index = index

func _on_duration_timeout():
	if chasing:
		chasing = false
		chara.character_animations.set("parameters/WWalkBlend/blend_amount", 0)
		chara.total_attack_animations = 2
		chara.basic_attack.current_attack_index = index
		chara.can_cast = true
