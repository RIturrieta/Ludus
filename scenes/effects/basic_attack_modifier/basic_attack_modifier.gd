extends Effect
class_name BasicAttackModifierEffect

var duration: float = 0
var target_amount: int
var attack_quantity: int

var og_target_amount: int
var og_attack_quantity: int

static func create(duration_: float, target_amount_: int = 1, attack_quantity_: int = 1) -> BasicAttackModifierEffect:
	var scene = load("res://scenes/effects/basic_attack_modifier/basic_attack_modifier.tscn")
	var modifier: BasicAttackModifierEffect = scene.instantiate()
	modifier.duration = duration_
	modifier.target_amount = target_amount_
	modifier.attack_quantity = attack_quantity_
	return modifier

func _ready():
	timer.timeout.connect(stop)
	timer.start(duration)
	og_target_amount = chara.basic_attack.target_amount
	og_attack_quantity = chara.basic_attack.attack_quantity
	chara.basic_attack.target_amount = target_amount
	chara.basic_attack.attack_quantity = attack_quantity

func stop():
	chara.basic_attack.target_amount = og_target_amount
	chara.basic_attack.attack_quantity = og_attack_quantity
	queue_free()
