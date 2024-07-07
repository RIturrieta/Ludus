extends Ability

@export var max_hp_percentage: float = 0
@export var spell_power_percentage: float = 0
@export var attack_damage_multiplier: float = 1


func _ready():
	super()
	chara.modifyStats(-1, attack_damage_multiplier, spell_power_percentage, 0, 0, 1, 1, 0, 1, max_hp_percentage, 0, 0)
