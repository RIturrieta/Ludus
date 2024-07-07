extends Ability

@export var move_speed_percentage: float = 0
@export var attack_speed_multiplier: float = 1


func _ready():
	super()
	chara.modifyStats(-1, 1, 0, 0, 0, attack_speed_multiplier, 1, 0, 1, 0, 0, move_speed_percentage)
