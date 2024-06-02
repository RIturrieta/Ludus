extends Node
class_name Effect

#enum EffectType {Stun, Root, Slow, Silence, Modifier}
#@export var effect_type: EffectType
@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var timer: Timer = $timer


func _ready():
	timer.timeout.connect(onTimeout)
	timer.start()

func onTimeout():
	chara.remove_child(self)
