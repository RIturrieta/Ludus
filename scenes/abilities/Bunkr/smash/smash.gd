extends Ability
@onready var area: Area3D = $area
@onready var collision: CollisionShape3D = $area/collision

@export var radius: float = 6.5

func _ready():
	super()
	collision.shape.radius = radius
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	for player: BaseCharacter in area.get_overlapping_bodies():
		if player.team != chara.team:
			player.takeAbilityDamage(damage, chara.spell_power)
			player.modifySpeed(1.3, -15)

func endExecution():
	chara.can_cast = true
