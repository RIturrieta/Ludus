extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
var is_passive_active: bool = false
var players_on_area: Array
var dmg_area: Area3D
var timer: Timer
var damage: int = 150

func _ready():
	dmg_area = load("res://scenes/abilities/garrotazo/dmg_area.tscn").instantiate()
	timer = dmg_area.get_child(1)
	get_parent().add_sibling(dmg_area)
	timer.timeout.connect(_on_timeout)
	dmg_area.monitoring = true

func execute(spawn_pos: Vector3, forward: Vector3, rotation: float):
	Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	dmg_area.global_rotation_degrees = Vector3(0, rotation, 0)
	timer.start()
	
func _on_timeout():
	players_on_area = dmg_area.get_overlapping_bodies()
	for player in players_on_area:
		if player.get_parent() != chara.get_parent():
			player.hp -= damage*chara.spell_power
			Debug.sprint(player.get_parent().name + " recieved " + 
			String.num(damage*chara.spell_power) + 
			" and now has " + String.num(player.hp) + " hp")
	players_on_area = []

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
