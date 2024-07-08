extends Area3D

@export var speed: int = 9
var ray: RayCast3D
var forward_dir: Vector3 = Vector3(0,0,0)
var returning: bool = false


func _physics_process(delta):
	forward_dir.y = 1
	if global_position.distance_to(forward_dir) <= 0.5:
		global_position = lerp(global_position, forward_dir, 0.3)
	else:
		global_position = global_position.move_toward(forward_dir, delta*speed)
