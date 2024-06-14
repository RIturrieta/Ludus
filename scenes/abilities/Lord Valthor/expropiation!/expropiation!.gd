extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var preview: MeshInstance3D = $preview

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export var radius: float = 3

@onready var area: Area3D = $area
@onready var collision: CollisionShape3D = $area/shape
var players_on_area: int = 0
var og_spell_armor: float
var og_physical_armor: float

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

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		chara.abort_oneshots()
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		chara.character_animations.set("parameters/WShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	players_on_area = len(area.get_overlapping_bodies())
	# chara.spell_armor += 5 * players_on_area
	# chara.physical_armor += 5 * players_on_area
	chara.modifyStats(3, 1, 0, 5 * players_on_area, 5 * players_on_area, 1, 1, 0, 1)
	chara.heal(5 * players_on_area)
	Debug.sprint("players: " + str(players_on_area) + " sp: " + str(chara.spell_armor) + " ph: " + str(chara.physical_armor) )

func endExecution():
	pass

func _on_cd_timeout():
	on_cooldown = false
