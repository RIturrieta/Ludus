extends Effect
class_name SilenceEffect

var duration: float = 0

static func create(duration_: float) -> SilenceEffect:
	var scene = load("res://scenes/effects/silence/silence.tscn")
	var silence: SilenceEffect = scene.instantiate()
	silence.duration = duration_
	return silence

func _ready():
	timer.timeout.connect(onTimeout)
	timer.start(duration)
	chara.is_silenced = true

func onTimeout():
	chara.is_silenced = false
	queue_free()
