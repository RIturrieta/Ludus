extends Ability

@export_category("Stats")
@export var radius: float = 3

@onready var area: Area3D = $area
@onready var collision: CollisionShape3D = $area/shape
var players_on_area: int = 0
var og_spell_armor: float
var og_physical_armor: float

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	collision.shape.radius = radius

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.can_cast = false
		chara.character_animations.set("parameters/WShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	players_on_area = len(area.get_overlapping_bodies())
	# chara.spell_armor += 5 * players_on_area
	# chara.physical_armor += 5 * players_on_area
	chara.modifyStats(3, 1, 0, 5 * players_on_area, 5 * players_on_area, 1, 1, 0, 1)
	chara.heal(5 * players_on_area)
	Debug.sprint("players: " + str(players_on_area) + " sp: " + str(chara.spell_armor) + " ph: " + str(chara.physical_armor) )

func endExecution():
	chara.can_cast = true

func _on_cd_timeout():
	on_cooldown = false
