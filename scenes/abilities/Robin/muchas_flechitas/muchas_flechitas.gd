extends Ability

@export var range_radius: float = 1
@export var area_radius: float = 7
@export var pulse_delay: int = 30
@export var rain_duration: float = 7
@onready var rain_timer: Timer = $rain_timer
@onready var range_area: Area3D = $range_area
@onready var mouse_area: Area3D = $mouse_area
@onready var range_collision: CollisionShape3D = $range_area/collision
@onready var area_collision: CollisionShape3D = $mouse_area/collision
var casting: bool = false
var raining: bool = false
var pulse_frames: int = 0

func _ready():
	preview = $mouse_area/preview
	preview.mesh.top_radius = area_radius
	preview.mesh.bottom_radius = area_radius
	super()
	rain_timer.timeout.connect(_on_rain_timeout)
	range_collision.shape.radius = range_radius
	area_collision.shape.radius = area_radius
	
func _physics_process(delta):
	if not (casting or raining):
		if chara.mouse_pos.distance_to(chara.global_position) >= range_radius:
			var intersection_array = Geometry3D.segment_intersects_sphere(chara.mouse_pos, chara.global_position, chara.global_position, range_radius)
			if len(intersection_array) > 0:
				mouse_area.global_position = intersection_array[0]
		else:
			mouse_area.global_position = chara.mouse_pos
	elif raining:
		pulse_frames += 1
		if pulse_frames == pulse_delay:
			pulse_frames = 0
			for player: BaseCharacter in mouse_area.get_overlapping_bodies():
				if player.get_parent() != chara.get_parent():
					player.takeAbilityDamage(damage, chara.spell_power)

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		chara.can_act = false
		casting = true
		chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.can_act = true

func endExecution():
	casting = false
	raining = true
	rain_timer.start(rain_duration)
	preview.visible = true
	chara.can_act = true

func _on_rain_timeout():
	raining = false
	pulse_frames = 0
	preview.visible = false
	chara.can_cast = true
