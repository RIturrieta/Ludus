extends Node

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
	cd_timer.wait_time = cooldown

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		chara.can_act = false
		chara.character_animations.set("parameters/R2Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.modifyStats(8, 1.2, 20, -20, -20, 1.25, 1, 0, 1)
	chara.modifySpeed(8, 10)
	$duration.start()

func endExecution():
	chara.can_act = true

func _on_cd_timeout():
	on_cooldown = false

func _on_duration_timeout():
	var hair = chara.get_node("char3/Armature/Skeleton3D/Head/Hair")
	hair.visible = false
