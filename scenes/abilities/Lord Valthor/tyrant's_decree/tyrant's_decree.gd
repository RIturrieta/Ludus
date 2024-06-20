extends Ability

@export_category("Stats")
@export var radius: float = 1

@onready var range_area: Area3D = $range_area
@onready var mouse_area: Area3D = $mouse_area
@onready var collision: CollisionShape3D = $range_area/collision
var affected_player: BaseCharacter

func _ready():
	super()
	collision.shape.radius = radius
	
func _physics_process(_delta):
	if chara.mouse_pos.distance_to(chara.global_position) >= radius:
		var intersection_array = Geometry3D.segment_intersects_sphere(chara.mouse_pos, chara.global_position, chara.global_position, radius)
		if len(intersection_array) > 0:
			mouse_area.global_position = intersection_array[0]
	else:
		mouse_area.global_position = chara.mouse_pos

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		if mouse_area.has_overlapping_bodies():
			var min_distance: float = 999999
			var distance: float = 0
			for player in mouse_area.get_overlapping_bodies():
				if player.get_parent() != chara.get_parent():
					distance = player.global_position.distance_to(chara.global_position)
					if distance <= min_distance:
						min_distance = distance
						affected_player = player
			if affected_player != chara and affected_player != null:
				baseExecutionBegining()
				chara.character_node.look_at(affected_player.global_position, Vector3.UP)
				chara.can_cast = false
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
	chara.can_cast = true
	affected_player = null
