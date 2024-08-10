extends Effect
class_name StatsModifierEffect

var duration: float = 0

# Stat multipliers
var attack_damage: float
var spell_power: float
var physical_armor: float
var spell_armor: float
var attack_speed: float
var attack_range: float
var cdr: float
var select_radius: float
var max_hp: float
var max_mana: float
var move_speed: float



static func create( duration_: float, 
					attack_damage_: float = 1,  # multiplier
					spell_power_: float = 0,    # percentage
					physical_armor_: float = 0, # percentage
					spell_armor_: float = 0,    # percentage
					attack_speed_: float = 1,   # multiplier
					attack_range_: float = 1,   # multiplier
					cdr_: float = 0,            # percentage
					select_radius_: float = 1,  # multiplier
					max_hp_: float = 0,         # percentage
					max_mana_: float = 0,       # percentage
					move_speed_: float = 0      # percentage
					) -> StatsModifierEffect:
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
	modifier.max_hp = max_hp_
	modifier.max_mana = max_mana_
	modifier.move_speed = move_speed_
	return modifier

func _ready():
	if duration > 0:
		timer.timeout.connect(stop)
		timer.wait_time = duration
		timer.start()
	chara.attack_damage *= attack_damage
	#chara.spell_power *= (1 + spell_power/100)
	#chara.physical_armor *= (1 + physical_armor/100)
	#chara.spell_armor *= (1 + spell_armor/100)
	chara.spell_power += spell_power
	chara.physical_armor += physical_armor
	chara.spell_armor += spell_armor
	chara.attack_speed *= attack_speed
	for i in range(chara.total_attack_animations):
		chara.character_animations.set("parameters/AttackMul" + str(i + 1) + "/scale", chara.attack_speed)
	chara.attack_range *= attack_range
	#chara.cdr *= (1 + cdr/100)
	chara.cdr += cdr
	chara.select_radius *= select_radius
	chara.max_hp *= (1 + max_hp/100)
	chara.bars.update_size()
	if chara.hp >= chara.max_hp:
		chara.hp = chara.max_hp
	chara.max_mana *= (1 + max_mana/100)
	if chara.mana >= chara.max_mana:
		chara.mana = chara.max_mana
	chara.move_speed *= (1 + move_speed/100)

func stop():
	chara.attack_damage /= attack_damage
	#chara.spell_power /= (1 + spell_power/100)
	#chara.physical_armor /= (1 + physical_armor/100)
	#chara.spell_armor /= (1 + spell_armor/100)
	chara.spell_power -= spell_power
	chara.physical_armor -= physical_armor
	chara.spell_armor -= spell_armor
	chara.attack_speed /= attack_speed
	for i in range(chara.total_attack_animations):
		chara.character_animations.set("parameters/AttackMul" + str(i + 1) + "/scale", chara.attack_speed)
	chara.attack_range /= attack_range
	#chara.cdr /= (1 + cdr/100)
	chara.cdr -= cdr
	chara.select_radius /= select_radius
	chara.max_hp /= (1 + max_hp/100)
	chara.bars.update_size()
	if chara.hp >= chara.max_hp:
		chara.hp = chara.max_hp
	chara.max_mana /= (1 + max_mana/100)
	if chara.mana >= chara.max_mana:
		chara.mana = chara.max_mana
	chara.move_speed /= (1 + move_speed/100)
	queue_free()
