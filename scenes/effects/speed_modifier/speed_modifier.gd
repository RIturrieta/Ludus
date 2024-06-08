extends Effect
class_name SpeedModifierEffect

var duration: float = 0
var percentage: float = 0
var is_applied: bool = false

static func create(duration_: float, percentage_: float) -> SpeedModifierEffect:
	var scene = load("res://scenes/effects/speed_modifier/speed_modifier.tscn")
	var modifier: SpeedModifierEffect = scene.instantiate()
	modifier.duration = duration_
	modifier.percentage = percentage_
	return modifier

func _ready():
	timer.timeout.connect(onTimeout)
	timer.start(duration)

func apply():
	is_applied = true
	chara.move_speed *= (1 + percentage/100)

func unapply():
	is_applied = false
	chara.move_speed /= (1 + percentage/100)

func onTimeout():
	if is_applied:
		unapply()
	queue_free()
