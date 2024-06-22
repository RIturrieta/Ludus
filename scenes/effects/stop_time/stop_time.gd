extends Effect
class_name StopTimeEffect

var duration: float = 0
var og_can_act
var og_can_move
var og_can_rotate
var og_can_cast

static func create(duration_: float) -> StopTimeEffect:
	var scene = load("res://scenes/effects/stop_time/stop_time.tscn")
	var stun: StopTimeEffect = scene.instantiate()
	stun.duration = duration_
	return stun

func _ready():
	og_can_act = chara.can_act
	og_can_move = chara.can_move
	og_can_rotate = chara.can_rotate
	og_can_cast = chara.can_cast
	timer.timeout.connect(onTimeout)
	timer.start(duration)
	stopTime.rpc()
	
func stop():
	timer.stop()
	queue_free()

func onTimeout():
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
	chara.can_act = og_can_act
	chara.can_move = og_can_move
	chara.can_rotate = og_can_rotate
	chara.can_cast = og_can_cast
	chara.character_animations.set("parameters/TimeScale/scale", 1)
	for i in range(chara.total_attack_animations):
		chara.character_animations.set("parameters/AttackMul" + str(i + 1) + "/scale", chara.attack_speed)
	chara.character_animations.set("parameters/QMul/scale", 1)
	chara.character_animations.set("parameters/WMul/scale", 1)
	chara.character_animations.set("parameters/EMul/scale", 1)
	chara.character_animations.set("parameters/R1Mul/scale", 1)
	chara.character_animations.set("parameters/R2Mul/scale", 1)

