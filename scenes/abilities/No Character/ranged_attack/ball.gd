extends Area3D

@export var speed: int = 9
var ray: RayCast3D
var forward_dir: Vector3 = Vector3(0,0,0)
var returning: bool = false
var target: BaseCharacter = null


func _physics_process(delta):
	forward_dir = target.global_position
	forward_dir.y = 1
	look_at(forward_dir, Vector3.UP)
	global_position = global_position.move_toward(forward_dir, delta * speed)
