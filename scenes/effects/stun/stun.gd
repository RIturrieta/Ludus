extends Effect
class_name StunEffect

var duration: float = 0

static func create(duration_: float) -> StunEffect:
	var scene = load("res://scenes/effects/stun/stun.tscn")
	var stun: StunEffect = scene.instantiate()
	stun.duration = duration_
	return stun

func _ready():
	timer.timeout.connect(stop)
	timer.start(duration)
	if is_multiplayer_authority():
		stopTime.rpc()
	chara.updateTargetLocation(chara.global_position)

func stop():
	if is_multiplayer_authority():
		resumeTime.rpc()
	queue_free()

@rpc("reliable","call_local")
func stopTime():
	chara.basic_attack.target_player = null
	chara.can_act = false
	chara.can_move = false
	chara.can_rotate = false
	chara.can_cast = false

	chara.character_animations.set("parameters/TimeScale/scale", 0)
	for i in range(chara.total_attack_animations):
		chara.character_animations.set("parameters/AttackMul" + str(i + 1) + "/scale", 0)
	chara.character_animations.set("parameters/QMul/scale", 0)
	chara.character_animations.set("parameters/WMul/scale", 0)
	chara.character_animations.set("parameters/EMul/scale", 0)
	chara.character_animations.set("parameters/R1Mul/scale", 0)
	chara.character_animations.set("parameters/R2Mul/scale", 0)
	
@rpc("reliable","call_local")
func resumeTime():
	chara.can_act = true
	chara.can_move = true
	chara.can_rotate = true
	chara.can_cast = true
	chara.character_animations.set("parameters/TimeScale/scale", 1)
	for i in range(chara.total_attack_animations):
		chara.character_animations.set("parameters/AttackMul" + str(i + 1) + "/scale", chara.attack_speed)
	chara.character_animations.set("parameters/QMul/scale", 1)
	chara.character_animations.set("parameters/WMul/scale", 1)
	chara.character_animations.set("parameters/EMul/scale", 1)
	chara.character_animations.set("parameters/R1Mul/scale", 1)
	chara.character_animations.set("parameters/R2Mul/scale", 1)
