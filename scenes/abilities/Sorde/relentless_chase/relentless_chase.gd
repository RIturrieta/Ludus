extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview

@export_category("Stats")
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export var radius: float = 1
@export var duration: float = 3

@onready var area_range: Area3D = $area_range
@onready var area_mouse: Area3D = $area_mouse
@onready var collision: CollisionShape3D = $area_range/collision
@onready var duration_timer: Timer = $duration
var chara_animations: AnimationTree
var chasing: bool = false
var index

var on_cooldown: bool = false

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	duration_timer.timeout.connect(_on_duration_timeout)
	duration_timer.wait_time = duration
	collision.shape.radius = radius

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		index = chara.attack_animation_index
		chara.total_attack_animations = 3
		chara.attack_animation_index = 2
		chara.character_animations.set("parameters/WWalkBlend/blend_amount", 1)
		chara.modifySpeed(duration, 100)
		chara.modifyStats(duration, 1.75)
		duration_timer.start()
		chasing = true

func _physics_process(delta):
	area_mouse.global_position = chara.mouse_pos

func execute():
	chasing = false
	var target_player = chara.get_target_player(chara.target)
	if target_player != null:
		target_player.modifySpeed(2, -30)
	chara.total_attack_animations = 2
	chara.attack_animation_index = index

func endExecution():
	chara.clearStatsModifier(duration, 1.75)
	chara.clearSpeedModifier(duration, 100)
	chara.character_animations.set("parameters/WWalkBlend/blend_amount", 0)
	#chara.total_attack_animations = 2
	#chara.attack_animation_index = index

func _on_duration_timeout():
	if chasing:
		chasing = false
		chara.character_animations.set("parameters/WWalkBlend/blend_amount", 0)
		chara.total_attack_animations = 2
		chara.attack_animation_index = index

func _on_cd_timeout():
	on_cooldown = false
