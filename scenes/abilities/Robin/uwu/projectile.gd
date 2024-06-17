extends Area3D

@export var speed: int = 10
var ray: RayCast3D
var forward_dir: Vector3 = Vector3(0,0,0)
var traveled_distance: float = 0

func _physics_process(delta):
	global_translate(forward_dir * speed * delta)
	traveled_distance += speed * delta
