extends Node

var is_passive_active: bool = false

func execute(chara: BaseCharacter, p_spawn_pos: Vector3, forward: Vector3):
	Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	# [Insert the ability here]
	pass

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
