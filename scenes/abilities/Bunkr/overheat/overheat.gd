extends Ability
@onready var area: Area3D = $area
@onready var timer: Timer = $timer
var burning: bool = false
@export var duration: float = 5
@export var pulse_delay: int = 5
var pulse_frames: int = 0

func _ready():
	super()
	timer.timeout.connect(on_timeout)

func _physics_process(delta):
	if burning:
		pulse_frames += 1
		if pulse_frames == pulse_delay:
			pulse_frames = 0
			for player: BaseCharacter in area.get_overlapping_bodies():
				if player.team != chara.team:
					if is_multiplayer_authority():
						player.takeAbilityDamage.rpc(damage, chara.spell_power)

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.can_cast = true
		execute()

func execute():
	burning = true
	chara.modifySpeed(duration, 25)
	preview.visible = true
	timer.start(duration)

func on_timeout():
	burning = false
	preview.visible = false
