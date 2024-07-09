extends Area3D

@export var speed: int = 14
@export var return_speed: int = 25
var ray: RayCast3D
var forward_dir: Vector3 = Vector3(0,0,0)
var returning: bool = false


func _physics_process(delta):
	forward_dir.y = 1
	if returning:
		speed = return_speed
	global_position = global_position.move_toward(forward_dir, delta * speed)
