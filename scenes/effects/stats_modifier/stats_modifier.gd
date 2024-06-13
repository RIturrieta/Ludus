extends Effect
class_name StatsModifierEffect

var duration: float = 0

# Stat multipliers
var hp: float
var mana: float
var attack_damage: float
var spell_power: float
var physical_armor: float
var spell_armor: float
var move_speed: float
var attack_speed: float
var attack_range: float
var cdr: float
var select_radius: float


static func create( duration_: float, 
					attack_damage_: float = 1, 
					spell_power_: float = 0, 
					physical_armor_: float = 0, 
					spell_armor_: float = 0, 
					attack_speed_: float = 1,
					attack_range_: float = 1,
					cdr_: float = 0,
					select_radius_: float = 1) -> StatsModifierEffect:
	var scene = load("res://scenes/effects/stats_modifier/stats_modifier.tscn")
	var modifier: StatsModifierEffect = scene.instantiate()
	modifier.duration = duration_
	modifier.attack_damage = attack_damage_
	modifier.spell_power = spell_power_
	modifier.physical_armor = physical_armor_
	modifier.spell_armor= spell_armor_
	modifier.attack_speed = attack_speed_
	modifier.attack_range = attack_range_
	modifier.cdr = cdr_
	modifier.select_radius = select_radius_
	return modifier

func _ready():
	if (duration > 0):
		timer.timeout.connect(stop)
	chara.attack_damage *= attack_damage
	chara.spell_power *= (1 + spell_power/100)
	chara.physical_armor *= (1 + physical_armor/100)
	chara.spell_armor *= (1 + spell_armor/100)
	chara.character_animations.set("parameters/AttackMul/scale", attack_speed/chara.attack_speed)
	chara.attack_speed *= attack_speed
	chara.attack_range *= attack_range
	chara.cdr += cdr
	chara.select_radius *= select_radius
	timer.wait_time = duration
	timer.start()

func stop():
	chara.attack_damage /= attack_damage
	chara.spell_power /= (1 + spell_power/100)
	chara.physical_armor /= (1 + physical_armor/100)
	chara.spell_armor /= (1 + spell_armor/100)
	chara.character_animations.set("parameters/AttackMul/scale", chara.initial_attack_speed/attack_speed)
	chara.attack_speed /= attack_speed
	chara.attack_range /= attack_range
	chara.cdr -= cdr
	chara.select_radius /= select_radius
	queue_free()
