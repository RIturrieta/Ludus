extends Effect
class_name CongregatioMarkEffect

@onready var range_area: Area3D = $range_area
@export var radius: float = 8
@export var duration: float = 4.5
@export var damage: float = 400
var attacker_team: Statics.Role = Statics.Role.NONE

static func create(attacker_team_: Statics.Role) -> CongregatioMarkEffect:
	var scene = load("res://scenes/effects/congregatio_mark/congregatio_mark.tscn")
	var mark: CongregatioMarkEffect = scene.instantiate()
	mark.attacker_team = attacker_team_
	return mark

func _ready():
	var collision = $range_area/collision
	var mark = $range_area/mark
	collision.shape.radius = radius
	mark.mesh.top_radius = radius
	mark.mesh.bottom_radius = radius
	global_position = chara.global_position
	timer.timeout.connect(onTimeout)
	timer.start(duration)

func onTimeout():
	for player: BaseCharacter in range_area.get_overlapping_bodies():
		if player.team != attacker_team:
			player.stun(1.2)
			player.fixedMovement.rpc(chara.global_position, 17)
	queue_free()
