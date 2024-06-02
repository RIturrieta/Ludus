extends Effect
class_name SlowEffect

var duration: float = 0
var multiplier: float = 1
var is_applied: bool = false

static func create(duration_: float, multiplier_: float) -> SlowEffect:
	var scene = load("res://scenes/effects/slow/slow.tscn")
	var slow: SlowEffect = scene.instantiate()
	slow.duration = duration_
	slow.multiplier = multiplier_
	return slow

func _ready():
	timer.timeout.connect(onTimeout)
	timer.start(duration)

func apply():
	is_applied = true
	chara.move_speed *= multiplier

func unapply():
	is_applied = false
	chara.move_speed /= multiplier

func onTimeout():
	if is_applied:
		unapply()
	queue_free()
