extends Ability

@onready var area: Area3D = $area
@onready var collision: CollisionShape3D = $area/collision
@onready var timer: Timer = $timer

@export var radius: float = 11
@export var delay: float = 6.5
var bombing: bool = false

func _physics_process(delta):
	if not bombing:
		area.global_position = chara.mouse_pos

func _ready():
	timer.timeout.connect(on_timeout)
	preview.mesh.top_radius = radius
	preview.mesh.bottom_radius = radius
	super()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		execute()

func execute():
	chara.root(delay)
	timer.start(delay)
	preview.visible = true
	bombing = true

func on_timeout():
	preview.visible = false
	for player: BaseCharacter in area.get_overlapping_bodies():
		if player.team != chara.team:
			player.takeAbilityDamage(damage, chara.spell_power)
	bombing = false
	chara.can_cast = true
