extends Effect
class_name RootEffect

var duration: float = 0

static func create(duration_: float) -> RootEffect:
	var scene = load("res://scenes/effects/root/root.tscn")
	var root: RootEffect = scene.instantiate()
	root.duration = duration_
	return root

func _ready():
	timer.timeout.connect(stop)
	timer.start(duration)
	chara.can_move = false
	chara.can_rotate = false

func stop():
	chara.can_move = true
	chara.can_rotate = true
	queue_free()
