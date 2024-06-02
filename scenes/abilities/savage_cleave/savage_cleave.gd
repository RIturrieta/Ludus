extends Node

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cd_timer: Timer = $cd_timer
@onready var is_passive_active: bool = false

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
var chara_animations: AnimationTree

var players_on_area: Array
var hitbox: MeshInstance3D
var casting: bool = false
var dmg_area: Area3D

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	cd_timer.wait_time = cooldown
	p_ray = chara.projectile_ray
	p_spawn = chara.projectile_spawn
	p_forward = -p_ray.global_transform.basis.z.normalized()
	p_spawn_pos = p_spawn.global_position
	p_rotation = p_ray.rotation_degrees.y
	chara_animations = chara.character_animations
	dmg_area = $dmg_area
	hitbox = $dmg_area/hitbox
	hitbox.visible = false
	# delay = $dmg_area/delay
	# delay.timeout.connect(_on_delay_timeout)
	dmg_area.monitoring = true

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
		on_cooldown = true
		cd_timer.start()
		chara.mana -= mana_cost
		hitbox.visible = true
		chara_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.clearRoots()
	chara.clearSlows()
	players_on_area = dmg_area.get_overlapping_bodies()
	for player in players_on_area:
		if player.get_parent() != chara.get_parent():
			player.hp -= (damage* (chara.spell_power / 100)) * (player.spell_armor / 100)
			Debug.sprint(player.get_parent().name + " recieved " + 
			String.num((damage*(chara.spell_power / 100)) * (player.spell_armor / 100)) + 
			" and now has " + String.num(player.hp) + " hp")
			if player.died():
				if chara.target_player:
					chara.target_player = null

func endExecution():
	casting = false
	players_on_area = []
	chara.can_move = true
	chara.can_rotate = true
	hitbox.visible = false

func _on_cd_timeout():
	on_cooldown = false

# note: if the passive effect can affect the teammate, the character class will
# need a reference to their teammate
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	# [Insert the passive effect here]
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	# [Undo the passive effect here]
	pass
