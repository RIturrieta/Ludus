extends Effect
class_name StunEffect

var duration: float = 0

static func create(duration_: float) -> StunEffect:
	var scene = load("res://scenes/effects/stun/stun.tscn")
	var stun: StunEffect = scene.instantiate()
	stun.duration = duration_
	return stun

func _ready():
	timer.timeout.connect(onEffectTimeout)
	timer.start()
	chara.can_act = false

func onEffectTimeout():
	# this is incorrect lol
	chara.can_act = true
	chara.remove_child(self)
