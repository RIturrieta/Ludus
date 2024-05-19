extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
var on_cooldown: bool = false

var projectile = load("res://scenes/abilities/skillshot_test/projectile.tscn")

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown

func execute(spawn_pos: Vector3, forward: Vector3, rotation: float):
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		var p: RigidBody3D = projectile.instantiate()
		p.forward_dir = forward
		chara.add_sibling(p)
		p.global_position = spawn_pos

func _on_cd_timeout():
	on_cooldown = false
	
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	pass
