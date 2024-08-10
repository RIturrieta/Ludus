extends Control

#CHARACTER NODE
@onready var local_player: BaseCharacter

# CHARACTER BARS
@onready var chara_hp_bar: ProgressBar = $CharaInfo/VBoxContainer/CharaBars/HealthBar
@onready var chara_hp_label = $CharaInfo/VBoxContainer/CharaBars/HealthBar/Label
@onready var chara_mana_bar: ProgressBar = $CharaInfo/VBoxContainer/CharaBars/ManaBar
@onready var chara_mana_label = $CharaInfo/VBoxContainer/CharaBars/ManaBar/Label

# CHARACTER NAME
@onready var chara_name: Label = $CharaInfo/VBoxContainer/HBoxContainer/CharaName

# CHARACTER STATS
@onready var chara_ad = $CharaInfo/Stats/GridContainer/AttackDamage/Label
@onready var chara_sp = $CharaInfo/Stats/GridContainer/SpellPower/Label
@onready var chara_pa = $CharaInfo/Stats/GridContainer/PhysicalArmor/Label
@onready var chara_sa = $CharaInfo/Stats/GridContainer/SpellArmor/Label
@onready var chara_as = $CharaInfo/Stats/GridContainer/AttackSpeed/Label
@onready var chara_ar = $CharaInfo/Stats/GridContainer/AttackRange/Label
@onready var chara_cdr = $CharaInfo/Stats/GridContainer/CDR/Label
@onready var chara_ms = $CharaInfo/Stats/GridContainer/MoveSpeed/Label

# CHARACTER EFFECTS
@onready var chara_stun = $CharaInfo/VBoxContainer/HBoxContainer/Effects/Stun
@onready var chara_root = $CharaInfo/VBoxContainer/HBoxContainer/Effects/Root
@onready var chara_silence = $CharaInfo/VBoxContainer/HBoxContainer/Effects/Silence
@onready var chara_slow = $CharaInfo/VBoxContainer/HBoxContainer/Effects/Slow
@onready var chara_speed_boost = $CharaInfo/VBoxContainer/HBoxContainer/Effects/SpeedBoost
@onready var chara_modifier = $CharaInfo/VBoxContainer/HBoxContainer/Effects/Modifier


# TARGET NODE
@onready var target_player: BaseCharacter = null

# TARGET INFORMATION PANEL
@onready var target_info = $TargetInfo

# TARGET NAME
@onready var target_name = $TargetInfo/VBoxContainer/TargetName

# TARGET BARS
@onready var target_hp_bar: ProgressBar = $TargetInfo/VBoxContainer/TargetBars/HealthBar
@onready var target_hp_label = $TargetInfo/VBoxContainer/TargetBars/HealthBar/Label
@onready var target_mana_bar: ProgressBar = $TargetInfo/VBoxContainer/TargetBars/ManaBar
@onready var target_mana_label = $TargetInfo/VBoxContainer/TargetBars/ManaBar/Label

# TARGET STATS
@onready var target_ad = $TargetInfo/Stats/GridContainer/AttackDamage/Label
@onready var target_sp = $TargetInfo/Stats/GridContainer/SpellPower/Label
@onready var target_pa = $TargetInfo/Stats/GridContainer/PhysicalArmor/Label
@onready var target_sa = $TargetInfo/Stats/GridContainer/SpellArmor/Label
@onready var target_as = $TargetInfo/Stats/GridContainer/AttackSpeed/Label
@onready var target_ar = $TargetInfo/Stats/GridContainer/AttackRange/Label
@onready var target_cdr = $TargetInfo/Stats/GridContainer/CDR/Label
@onready var target_ms = $TargetInfo/Stats/GridContainer/MoveSpeed/Label

# TARGET BLESSINGS
@onready var target_b1 = $TargetInfo/VBoxContainer/TargetBlessings/B1/TargetB1
@onready var target_b2 = $TargetInfo/VBoxContainer/TargetBlessings/B2/TargetB2
@onready var target_b3 = $TargetInfo/VBoxContainer/TargetBlessings/B3/TargetB3
@onready var target_b4 = $TargetInfo/VBoxContainer/TargetBlessings/B4/TargetB4



func _ready():
	target_info.visible = false

# CHARA BAR UPDATES
func update_chara_hp(value: float):
	chara_hp_bar.value = local_player.health_bar.value
	chara_hp_label.text = str(snapped(local_player.health_bar.value, 0.1)) + " / " + str(snapped(chara_hp_bar.max_value, 0.1))

func update_chara_max_hp():
	chara_hp_bar.max_value = local_player.health_bar.max_value
	chara_hp_label.text = str(snapped(chara_hp_bar.value, 0.1)) + " / " + str(snapped(chara_hp_bar.max_value, 0.1))
	
func update_chara_mana(value: float):
	chara_mana_bar.value = local_player.mana_bar.value
	chara_mana_label.text = str(roundf(local_player.mana_bar.value)) + " / " + str(snapped(chara_mana_bar.max_value, 0.1))

func update_chara_max_mana():
	chara_mana_bar.max_value = local_player.mana_bar.max_value
	chara_mana_label.text = str(roundf(chara_mana_bar.value)) + " / " + str(snapped(chara_mana_bar.max_value, 0.1))

# TARGET BAR UPDATES
func update_target_hp(value: float):
	target_hp_bar.value = target_player.health_bar.value
	target_hp_label.text = str(snapped(target_player.health_bar.value, 0.1)) + " / " + str(snapped(target_hp_bar.max_value, 0.1))

func update_target_max_hp():
	target_hp_bar.max_value = target_player.health_bar.max_value
	target_hp_label.text = str(snapped(target_hp_bar.value, 0.1)) + " / " + str(snapped(target_hp_bar.max_value, 0.1))
	
func update_target_mana(value: float):
	target_mana_bar.value = target_player.mana_bar.value
	target_mana_label.text = str(roundf(target_player.mana_bar.value)) + " / " + str(snapped(target_mana_bar.max_value, 0.1))

func update_target_max_mana():
	target_mana_bar.max_value = target_player.mana_bar.max_value
	target_mana_label.text = str(roundf(target_mana_bar.value)) + " / " + str(snapped(target_mana_bar.max_value, 0.1))

func prepare_blessing(index: int):
	var inputs = ["1", "2", "3", "4"]
	var texture = local_player.abilities[inputs[index]][1].Icon
	var tooltip = local_player.abilities[inputs[index]][1].Name + "\n" + local_player.abilities[inputs[index]][1].Description
	if index == 0:
		%CharaB1.texture = texture
		%CharaB1.tooltip_text = tooltip
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$CharaInfo/CharaBlessings/B1/Charges.visible = true
		$CharaInfo/CharaBlessings/B1/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)
	elif index == 1:
		%CharaB2.texture = texture
		%CharaB2.tooltip_text = tooltip
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$CharaInfo/CharaBlessings/B2/Charges.visible = true
		$CharaInfo/CharaBlessings/B2/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)
	elif index == 2:
		%CharaB3.texture = texture
		%CharaB3.tooltip_text = tooltip
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$CharaInfo/CharaBlessings/B3/Charges.visible = true
		$CharaInfo/CharaBlessings/B3/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)
	else:
		%CharaB4.texture = texture
		%CharaB4.tooltip_text = tooltip
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$CharaInfo/CharaBlessings/B4/Charges.visible = true
		$CharaInfo/CharaBlessings/B4/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)

func prepare_icons(index: int = 0):
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == Game.get_current_player().id:
			local_player = player
			chara_name.text = local_player.get_parent().name
			update_chara_max_hp()
			update_chara_hp(0)
			update_chara_max_mana()
			update_chara_mana(chara_mana_bar.max_value)
			if !local_player.health_bar.value_changed.is_connected(update_chara_hp):
				local_player.health_bar.value_changed.connect(update_chara_hp)
			if !local_player.health_bar.changed.is_connected(update_chara_max_hp):
				local_player.health_bar.changed.connect(update_chara_max_hp)
			if !local_player.mana_bar.value_changed.is_connected(update_chara_mana):
				local_player.mana_bar.value_changed.connect(update_chara_mana)
			if !local_player.mana_bar.changed.is_connected(update_chara_max_mana):
				local_player.mana_bar.changed.connect(update_chara_max_mana)
			
	var texture_q = local_player.abilities["Q"][1].Icon
	var tooltip_q = local_player.abilities["Q"][1].Name + "\n" + local_player.abilities["Q"][1].Description
	%CharaQ.texture = texture_q
	%CharaQ.tooltip_text = tooltip_q
	if local_player.abilities["Q"][1].total_charges > 0:
		$CharaInfo/CharaAbilities/Q/Charges.visible = true
	$CharaInfo/CharaAbilities/Q/Charges/Counter.text = str(local_player.abilities["Q"][1].charges)
	
	var texture_w = local_player.abilities["W"][1].Icon
	var tooltip_w = local_player.abilities["W"][1].Name + "\n" + local_player.abilities["W"][1].Description
	%CharaW.texture = texture_w
	%CharaW.tooltip_text = tooltip_w
	if local_player.abilities["W"][1].total_charges > 0:
		$CharaInfo/CharaAbilities/W/Charges.visible = true
	$CharaInfo/CharaAbilities/W/Charges/Counter.text = str(local_player.abilities["W"][1].charges)
	
	var texture_e = local_player.abilities["E"][1].Icon
	var tooltip_e = local_player.abilities["E"][1].Name + "\n" + local_player.abilities["E"][1].Description
	%CharaE.texture = texture_e
	%CharaE.tooltip_text = tooltip_e
	if local_player.abilities["E"][1].total_charges > 0:
		$CharaInfo/CharaAbilities/E/Charges.visible = true
	$CharaInfo/CharaAbilities/E/Charges/Counter.text = str(local_player.abilities["E"][1].charges)
	
	if index != 0:
		var texture_r = local_player.abilities["R" + str(index)][1].Icon
		var tooltip_r = local_player.abilities["R" + str(index)][1].Name + "\n" + local_player.abilities["R" + str(index)][1].Description
		%CharaR.texture = texture_r
		%CharaR.tooltip_text = tooltip_r
		if local_player.abilities["R" + str(index)][1].total_charges > 0:
			$CharaInfo/CharaAbilities/R/Charges.visible = true
		$CharaInfo/CharaAbilities/R/Charges/Counter.text = str(local_player.abilities["R" + str(index)][1].charges)

func update_ability_icons():
	for key in ["Q","W","E","R"]:
		var panel = $CharaInfo/CharaAbilities
		var counter = panel.find_child(key).get_child(2).get_child(0)
		var ability: Ability
		if key == "R":
			if local_player.r_index == 0:
				continue
			elif local_player.r_index == 1:
				ability = local_player.abilities["R1"][1]
			elif local_player.r_index == 2:
				ability = local_player.abilities["R2"][1]
		else:
			ability = local_player.abilities[key][1]
		counter.text = str(ability.charges)
		if ability.charges == 0 and ability.charges < ability.total_charges:
			get_node("CharaInfo/CharaAbilities/" + key + "/Chara" + key).modulate = Color("1d1d1d")
		else:
			get_node("CharaInfo/CharaAbilities/" + key + "/Chara" + key).modulate = Color(1, 1, 1)
	for key in ["1","2","3","4"]:
		var panel = $CharaInfo/CharaBlessings
		var counter = panel.find_child("B" + key).get_child(2).get_child(0)
		var ability: Ability = local_player.abilities[key][1]
		counter.text = str(ability.charges)
		if ability.charges == 0 and ability.charges < ability.total_charges:
			get_node("CharaInfo/CharaBlessings/B" + key + "/CharaB" + key).modulate = Color("1d1d1d")
		else:
			get_node("CharaInfo/CharaBlessings/B" + key + "/CharaB" + key).modulate = Color(1, 1, 1)

func update_chara_stats():
	chara_ad.text = str(local_player.attack_damage)
	chara_sp.text = str(local_player.spell_power)
	chara_pa.text = str(local_player.physical_armor)
	chara_sa.text = str(local_player.spell_armor)
	chara_as.text = str(local_player.attack_speed)
	chara_ar.text = str(local_player.attack_range)
	chara_cdr.text = str(local_player.cdr)
	chara_ms.text = str(local_player.move_speed)

func update_chara_effects():
	var is_stun = false
	var is_root = false
	var is_silence = false
	var is_slow = false
	var is_speed_boost = false
	var is_modifier = false
	for effect: Effect in local_player.effects.get_children():
		if effect is StunEffect:
			is_stun = true
		if effect is RootEffect:
			is_root  = true
		if effect is SilenceEffect:
			is_silence = true
		if effect is SpeedModifierEffect:
			if effect.percentage < 0:
				is_slow  = true
			elif effect.percentage > 0:
				is_speed_boost = true
		if effect is StatsModifierEffect:
			is_modifier = true
	if is_stun:
		chara_stun.visible = true
	else:
		chara_stun.visible = false
	if is_root:
		chara_root.visible = true
	else:
		chara_root.visible = false
	if is_silence:
		chara_silence.visible = true
	else:
		chara_silence.visible = false
	if is_slow:
		chara_slow.visible = true
	else:
		chara_slow.visible = false
	if is_speed_boost:
		chara_speed_boost.visible = true
	else:
		chara_speed_boost.visible = false
	if is_modifier:
		chara_modifier.visible = true
	else:
		chara_modifier.visible = false

func update_target_stats():
	if target_player != null:
		target_ad.text = str(target_player.attack_damage)
		target_sp.text = str(target_player.spell_power)
		target_pa.text = str(target_player.physical_armor)
		target_sa.text = str(target_player.spell_armor)
		target_as.text = str(target_player.attack_speed)
		target_ar.text = str(target_player.attack_range)
		target_cdr.text = str(target_player.cdr)
		target_ms.text = str(target_player.move_speed)

func connect_target():
	if target_player != null:
		target_name.text = target_player.get_parent().name
		var b1_texture = target_player.abilities["1"][1].Icon
		target_b1.texture = b1_texture
		target_b2.texture = target_player.abilities["2"][1].Icon
		target_b3.texture = target_player.abilities["3"][1].Icon
		target_b4.texture = target_player.abilities["4"][1].Icon
		target_b1.tooltip_text = target_player.abilities["1"][1].Name + "\n" + target_player.abilities["1"][1].Description
		target_b2.tooltip_text = target_player.abilities["2"][1].Name + "\n" + target_player.abilities["2"][1].Description
		target_b3.tooltip_text = target_player.abilities["3"][1].Name + "\n" + target_player.abilities["3"][1].Description
		target_b4.tooltip_text = target_player.abilities["4"][1].Name + "\n" + target_player.abilities["4"][1].Description
		update_target_max_hp()
		update_target_hp(target_player.hp)
		update_target_max_mana()
		update_target_mana(target_player.mana)
		
		if !target_player.health_bar.value_changed.is_connected(update_target_hp):
			target_player.health_bar.value_changed.connect(update_target_hp)
		if !target_player.health_bar.changed.is_connected(update_target_max_hp):
			target_player.health_bar.changed.connect(update_target_max_hp)
		if !target_player.mana_bar.value_changed.is_connected(update_target_mana):
			target_player.mana_bar.value_changed.connect(update_target_mana)
		if !target_player.mana_bar.changed.is_connected(update_target_max_mana):
			target_player.mana_bar.changed.connect(update_target_max_mana)

func disconnect_target():
	if target_player != null:
		if target_player.health_bar.value_changed.is_connected(update_target_hp):
			target_player.health_bar.value_changed.disconnect(update_target_hp)
		if target_player.health_bar.changed.is_connected(update_target_max_hp):
			target_player.health_bar.changed.disconnect(update_target_max_hp)
		if target_player.mana_bar.value_changed.is_connected(update_target_mana):
			target_player.mana_bar.value_changed.disconnect(update_target_mana)
		if target_player.mana_bar.changed.is_connected(update_target_max_mana):
			target_player.mana_bar.changed.disconnect(update_target_max_mana)
		target_info.visible = false

func _physics_process(delta):
	if Input.is_action_just_pressed("Select Player") or Input.is_action_just_pressed("Move"):
		var new_target: BaseCharacter = null
		if local_player.abilities["BA"][1].target_player == null:
			if Input.is_action_just_pressed("Select Player"):
				new_target = local_player.get_target_player(local_player.mouse_pos)
			else:
				new_target = target_player
		else:
			new_target = local_player.abilities["BA"][1].target_player
		if new_target != target_player:
			disconnect_target()
		target_player = new_target
		if target_player != local_player and target_player != null:
			connect_target()
			target_info.visible = true
		else:
			target_info.visible = false
		
	update_target_stats()
	update_chara_stats()
	update_chara_effects()
	update_ability_icons()
		
