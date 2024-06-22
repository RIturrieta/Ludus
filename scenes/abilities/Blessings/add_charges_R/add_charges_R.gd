extends Ability

@export var charge_amount: int = 2
@export var duration: float = -1

func _ready():
	super()
	var effect: ChargesModifierEffect = ChargesModifierEffect.create(duration, 0, 0, 0, charge_amount)
	chara.applyEffect(effect)
	
