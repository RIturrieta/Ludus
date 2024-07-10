extends Effect
class_name FragorMarkEffect

@onready var range_area: Area3D = $range_area
@export var radius: float = 3
@export var duration: float = 4.5
@export var damage: float = 400
var attacker_team: Statics.Role = Statics.Role.NONE
var spell_power: float = 1

static func create(attacker_team_: Statics.Role, spell_power_: float) -> FragorMarkEffect:
	var scene = load("res://scenes/effects/fragor_mark/fragor_mark.tscn")
	var mark: FragorMarkEffect = scene.instantiate()
	mark.attacker_team = attacker_team_
	mark.spell_power = spell_power_
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
			if is_multiplayer_authority():
				player.takeAbilityDamage.rpc(damage, spell_power)
			if player.get_parent() != chara.get_parent():
				var effect = FragorMarkEffect.create(attacker_team, spell_power)
				player.applyEffect(effect)
	queue_free()
