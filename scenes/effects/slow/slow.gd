extends Effect
class_name SlowEffect

var duration: float = 0
var multiplier: float = 1

static func create(duration_: float, multiplier_: float) -> SlowEffect:
	var scene = load("res://scenes/effects/slow/slow.tscn")
	var slow: SlowEffect = scene.instantiate()
	slow.duration = duration_
	slow.multiplier = multiplier_
	return slow

func _ready():
	timer.timeout.connect(onEffectTimeout)
	timer.start(duration)
	chara.move_speed *= multiplier

func onEffectTimeout():
	chara.move_speed /= multiplier
	chara.remove_child(self)
