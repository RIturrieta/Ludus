extends Node
class_name Ability

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6

var on_cooldown: bool = false

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)

func baseExecutionBegining():
	Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	chara.abort_oneshots()
	chara.updateTargetLocation(chara.global_position)
	on_cooldown = true
	cd_timer.start(cooldown - chara.cdr/100)
	chara.mana -= mana_cost
	
func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()

func execute():
	# [Insert the ability here]
	pass

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	on_cooldown = false
