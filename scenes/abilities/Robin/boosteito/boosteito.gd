extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6

var on_cooldown: bool = false

var p_ray: RayCast3D
var p_spawn: Node3D
var p_forward: Vector3
var p_spawn_pos: Vector3
var p_rotation: float

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	p_ray = chara.projectile_ray
	p_spawn = chara.projectile_spawn
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		chara.abort_oneshots()
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost

func execute():
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y
	# [Insert the ability here]

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	on_cooldown = false
