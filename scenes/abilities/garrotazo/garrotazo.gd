extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
var on_cooldown: bool = false
var projectile_ray: RayCast3D
var projectile_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

var players_on_area: Array
var dmg_area: Area3D
var delay: Timer

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	projectile_ray = chara.projectile_ray
	projectile_spawn = chara.projectile_spawn
	p_forward = -projectile_ray.global_transform.basis.z.normalized()
	p_spawn_pos = projectile_spawn.global_position
	p_rotation = projectile_ray.rotation_degrees.y
	dmg_area = load("res://scenes/abilities/garrotazo/dmg_area.tscn").instantiate()
	delay = dmg_area.get_child(1)
	get_parent().add_sibling(dmg_area)
	delay.timeout.connect(_on_delay_timeout)
	dmg_area.monitoring = true

func execute():
	if not on_cooldown and chara.mana >= mana_cost:
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		p_forward = -projectile_ray.global_transform.basis.z.normalized()
		p_spawn_pos = projectile_spawn.global_position
		p_rotation = projectile_ray.rotation_degrees.y
		dmg_area.global_rotation_degrees = Vector3(0, p_rotation, 0)
		delay.start()
	
func _on_delay_timeout():
	players_on_area = dmg_area.get_overlapping_bodies()
	for player in players_on_area:
		if player.get_parent() != chara.get_parent():
			player.hp -= damage*chara.spell_power
			Debug.sprint(player.get_parent().name + " recieved " + 
			String.num(damage*chara.spell_power) + 
			" and now has " + String.num(player.hp) + " hp")
	players_on_area = []

func _on_cd_timeout():
	on_cooldown = false

# note: if the passive effect can affect the teammate, the character class will
# need a reference to their teammate
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	# [Insert the passive effect here]
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	# [Undo the passive effect here]
	pass
