class_name Statics
extends Node


const MAX_CLIENTS = 1
const PORT = 5409


enum Role {
	NONE,
	TEAM_A,
	TEAM_B
}


class PlayerData:
	var id: int
	var name: String
	var role: Role
	
	func _init(new_id: int, new_name: String, new_role: Role = Role.NONE) -> void:
		id = new_id
		name = new_name
		role = new_role
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"role": role
		}
