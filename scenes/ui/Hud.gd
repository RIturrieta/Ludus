extends Control

var panels = []

func _ready():

	var hbox1 = get_node("HBoxContainer")
	var hbox2 = get_node("HBoxContainer2")

	for panel in hbox1.get_children():
		panels.append(panel)
	for panel in hbox2.get_children():
		panels.append(panel)

func prepare_blessing(index: int):
	var player_nodes = get_tree().get_nodes_in_group("players")
	var local_player
	for player in player_nodes:
		if player.player_info.id == Game.get_current_player().id:
			local_player = player
	var inputs = ["1", "2", "3", "4"]
	var style : StyleBoxTexture = StyleBoxTexture.new()
	style.texture = local_player.abilities[inputs[index]][1].Icon
	if index == 0:
		$HBoxContainer2/B1.add_theme_stylebox_override ("panel", style)
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$HBoxContainer2/B1/Charges.visible = true
		$HBoxContainer2/B1/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)
	elif index == 1:
		$HBoxContainer2/B2.add_theme_stylebox_override ("panel", style)
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$HBoxContainer2/B2/Charges.visible = true
		$HBoxContainer2/B2/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)
	elif index == 2:
		$HBoxContainer2/B3.add_theme_stylebox_override ("panel", style)
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$HBoxContainer2/B3/Charges.visible = true
		$HBoxContainer2/B3/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)
	else:
		$HBoxContainer2/B4.add_theme_stylebox_override ("panel", style)
		if local_player.abilities[inputs[index]][1].total_charges > 0:
			$HBoxContainer2/B4/Charges.visible = true
		$HBoxContainer2/B4/Charges/Counter.text = str(local_player.abilities[inputs[index]][1].charges)

func prepare_icons(index: int = 0):
	var player_nodes = get_tree().get_nodes_in_group("players")
	var local_player
	for player in player_nodes:
		if player.player_info.id == Game.get_current_player().id:
			local_player = player
	var style : StyleBoxTexture = StyleBoxTexture.new()
	style.texture = local_player.abilities["Q"][1].Icon
	$HBoxContainer/Q.add_theme_stylebox_override ("panel", style)
	$HBoxContainer/Q/Charges/Counter.text = str(local_player.abilities["Q"][1].charges)
	var style2 : StyleBoxTexture = StyleBoxTexture.new()
	style2.texture = local_player.abilities["W"][1].Icon
	$HBoxContainer/W.add_theme_stylebox_override ("panel", style2)
	$HBoxContainer/W/Charges/Counter.text = str(local_player.abilities["W"][1].charges)
	var style3 : StyleBoxTexture = StyleBoxTexture.new()
	style3.texture = local_player.abilities["E"][1].Icon
	$HBoxContainer/E.add_theme_stylebox_override ("panel", style3)
	$HBoxContainer/E/Charges/Counter.text = str(local_player.abilities["E"][1].charges)
	if index != 0:
		var style4 : StyleBoxTexture = StyleBoxTexture.new()
		style4.texture = local_player.abilities["R" + str(index)][1].Icon
		$HBoxContainer/R.add_theme_stylebox_override ("panel", style4)
		$HBoxContainer/R/Charges.visible = true
		$HBoxContainer/R/Charges/Counter.text = str(local_player.abilities["R" + str(index)][1].charges)

func _physics_process(delta):
	var player_nodes = get_tree().get_nodes_in_group("players")
	var player
	for player_ in player_nodes:
		if player_.player_info.id == Game.get_current_player().id:
			player = player_
	for key in ["Q","W","E","R"]:
		var panel = $HBoxContainer
		var counter = panel.find_child(key).get_child(1).get_child(0)
		var ability: Ability
		if key == "R":
			if player.r_index == 0:
				continue
			elif player.r_index == 1:
				ability = player.abilities["R1"][1]
			elif player.r_index == 2:
				ability = player.abilities["R2"][1]
		else:
			ability = player.abilities[key][1]
		counter.text = str(ability.charges)
		var styleBox: StyleBoxTexture = panel.find_child(key).get_theme_stylebox("panel")
		if ability.charges == 0 and ability.charges < ability.total_charges:
			styleBox.set("modulate_color", Color(0, 0, 0))
			panel.find_child(key).get_child(0).set("theme_override_colors/font_color", Color(0, 0, 0))
		else:
			styleBox.set("modulate_color", Color(1, 1, 1))
			panel.find_child(key).get_child(0).set("theme_override_colors/font_color", Color(1, 1, 1))

	for key in ["1","2","3","4"]:
		var panel = $HBoxContainer2
		var counter = panel.find_child("B" + key).get_child(1).get_child(0)
		var ability: Ability = player.abilities[key][1]
		counter.text = str(ability.charges)
		var styleBox: StyleBoxTexture = panel.find_child("B" + key).get_theme_stylebox("panel")
		if ability.charges == 0 and ability.charges < ability.total_charges:
			styleBox.set("modulate_color", Color(0, 0, 0))
			panel.find_child("B" + key).get_child(0).set("theme_override_colors/font_color", Color(0, 0, 0))
		else:
			styleBox.set("modulate_color", Color(1, 1, 1))
			panel.find_child("B" + key).get_child(0).set("theme_override_colors/font_color", Color(1, 1, 1))
