extends Node

var is_passive_active: bool = false

var projectile = load("res://scenes/abilities/skillshot_test/projectile.tscn")

func execute(chara: BaseCharacter, p_spawn_pos: Vector3, forward: Vector3):
	Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	var p: RigidBody3D = projectile.instantiate()
	var spawn_pos: Vector3 = chara.projectile_spawn.global_position
	p.forward_dir = forward
	chara.add_sibling(p)
	p.global_position = p_spawn_pos
	
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	pass
