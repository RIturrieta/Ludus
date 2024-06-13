extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export var radius: float = 1

@onready var area_range: Area3D = $area_range
@onready var area_mouse: Area3D = $area_mouse
@onready var collision: CollisionShape3D = $area_range/collision
var chara_animations: AnimationTree
var affected_player: BaseCharacter

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
	collision.shape.radius = radius
	chara_animations = chara.character_animations
	
func _physics_process(_delta):
	area_mouse.global_position = chara.mouse_pos

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		if area_mouse.has_overlapping_bodies() and area_range.has_overlapping_bodies():
			var min_distance: float = 999999
			var distance: float = 0
			for player in area_mouse.get_overlapping_bodies():
				if player.get_parent() != chara.get_parent() and player in area_range.get_overlapping_bodies():
					distance = player.global_position.distance_to(chara.global_position)
					if distance <= min_distance:
						min_distance = distance
						affected_player = player
			if affected_player != chara and affected_player != null:
				Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
				on_cooldown = true
				cd_timer.start()
				chara.mana -= mana_cost
				chara_animations.set("parameters/EShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else:
			affected_player = null
			

func execute():
	if affected_player == null:
		Debug.sprint("no players affected")
	else:
		Debug.sprint("Affected player: " + affected_player.get_parent().name)
		affected_player.stun(1.25)

func endExecution():
	affected_player = null

func _on_cd_timeout():
	on_cooldown = false
