extends Node

@onready var chara: CharacterBody3D = get_parent().get_parent()
var is_passive_active: bool = false

func execute(spawn_pos: Vector3, forward: Vector3, rotation: float):
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
