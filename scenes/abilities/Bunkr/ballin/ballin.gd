extends Ability
@onready var inner_area: Area3D = $inner_area
@onready var inner_collision: CollisionShape3D = $inner_area/inner_collision
@onready var outer_area = $outer_area
@onready var outer_collision = $outer_area/outer_collision

@export var inner_radius: float = 3
@export var outer_radius: float = 6.5

func _ready():
	super()
	inner_collision.shape.radius = inner_radius
	outer_collision.shape.radius = outer_radius
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		# chara.can_act = false
		chara.character_animations.set("parameters/R2Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		chara.collision_layer = 0b00001000

func execute():
	for player: BaseCharacter in inner_area.get_overlapping_bodies():
		if player.team != chara.team:
			player.stun(1.75)
	for player: BaseCharacter in outer_area.get_overlapping_bodies():
		if player.team != chara.team:
			var distance = max(1.0, player.global_position.distance_to(chara.global_position) - inner_radius + 1.0)
			var radial_damage = roundf(damage/distance)
			if is_multiplayer_authority():
				player.takeAbilityDamage.rpc(radial_damage, chara.spell_power)
			player.modifySpeed(4, -30)

func endExecution():
	chara.can_act = true
	chara.can_cast = true
	chara.collision_layer = 0b00000010
