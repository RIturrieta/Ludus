extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
var on_cooldown: bool = false

var players_on_area: Array
var dmg_area: Area3D
var delay: Timer

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	dmg_area = load("res://scenes/abilities/garrotazo/dmg_area.tscn").instantiate()
	delay = dmg_area.get_child(1)
	get_parent().add_sibling(dmg_area)
	delay.timeout.connect(_on_delay_timeout)
	dmg_area.monitoring = true

func execute(spawn_pos: Vector3, forward: Vector3, rotation: float):
	if not on_cooldown and chara.mana >= mana_cost:
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		print("mana: " + String.num(chara.mana))
		dmg_area.global_rotation_degrees = Vector3(0, rotation, 0)
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
