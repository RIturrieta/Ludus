class_name Statics
extends Node


const MAX_CLIENTS = 1
const PORT = 5409


enum Role {
	NONE,
	TEAM_A,
	TEAM_B
}

enum Character {
	NONE,
	CHAR1,
	CHAR2,
	CHAR3,
	CHAR4,
	CHAR5
}

class PlayerData:
	var id: int
	var name: String
	var slot: int
	var role: Role
	var character: Character
	var ready: bool = false
	
	func _init(new_id: int, new_name: String, new_slot: int, new_role: Role = Role.NONE, new_character: Character = Character.NONE) -> void:
		id = new_id
		name = new_name
		slot = new_slot
		role = new_role
		character = new_character
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"slot": slot,
			"role": role,
			"character": character
		}
