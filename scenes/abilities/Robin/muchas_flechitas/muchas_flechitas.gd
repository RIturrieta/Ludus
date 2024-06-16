extends Ability

@export var radius: float = 1

@onready var area_range: Area3D = $area_range
@onready var area_mouse: Area3D = $area_mouse
@onready var collision: CollisionShape3D = $area_range/collision
var affected_player: BaseCharacter

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)
	collision.shape.radius = radius
	
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
				baseExecutionBegining()
				chara.character_animations.set("parameters/EShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
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
