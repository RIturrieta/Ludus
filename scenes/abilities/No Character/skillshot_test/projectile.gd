extends Area3D

@export var speed: int = 14
var ray: RayCast3D
var forward_dir: Vector3 = Vector3(0,0,0)
#@onready var forward_dir = -ray.global_transform.basis.z.normalized()
func _physics_process(delta):
	global_translate(forward_dir * speed * delta)
