extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
var is_passive_active: bool = false

var projectile = load("res://scenes/abilities/skillshot_test/projectile.tscn")

func execute(spawn_pos: Vector3, forward: Vector3, rotation: float):
	Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	var p: RigidBody3D = projectile.instantiate()
	p.forward_dir = forward
	chara.add_sibling(p)
	p.global_position = spawn_pos
	
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	pass
