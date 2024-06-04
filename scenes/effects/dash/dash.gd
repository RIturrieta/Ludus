extends Effect
class_name DashEffect

var amount: float = 1

static func create(amount_: float) -> DashEffect:
	var scene = load("res://scenes/effects/dash/dash.tscn")
	var dash: DashEffect = scene.instantiate()
	dash.amount = amount_
	return dash

func _ready():
	pass

func apply():
	chara.move_speed = amount

func unapply():
	chara.move_speed = 100
