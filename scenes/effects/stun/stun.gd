extends Effect
class_name StunEffect

var duration: float = 0

static func create(duration_: float) -> StunEffect:
	var scene = load("res://scenes/effects/stun/stun.tscn")
	var stun: StunEffect = scene.instantiate()
	stun.duration = duration_
	return stun

func _ready():
	timer.timeout.connect(onTimeout)
	timer.start(duration)
	chara.can_act = false
	chara.updateTargetLocation(chara.global_position)

func stop():
	timer.stop()
	queue_free()

func onTimeout():
	chara.can_act = true
	queue_free()
