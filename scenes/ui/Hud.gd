extends Control

var panels = []

func _ready():

	var hbox1 = get_node("HBoxContainer")
	var hbox2 = get_node("HBoxContainer2")
	
	# Añade todos los paneles a la lista
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
	elif index == 1:
		$HBoxContainer2/B2.add_theme_stylebox_override ("panel", style)
	elif index == 2:
		$HBoxContainer2/B3.add_theme_stylebox_override ("panel", style)
	else:
		$HBoxContainer2/B4.add_theme_stylebox_override ("panel", style)

func prepare_icons(index: int = 0):
	var player_nodes = get_tree().get_nodes_in_group("players")
	var local_player
	for player in player_nodes:
		if player.player_info.id == Game.get_current_player().id:
			local_player = player
			
	# panel.get_child(0).set("theme_override_colors/font_color", Color(0, 0, 0))
	
	var style : StyleBoxTexture = StyleBoxTexture.new()
	style.texture = local_player.abilities["Q"][1].Icon
	$HBoxContainer/Q.add_theme_stylebox_override ("panel", style)
	var style2 : StyleBoxTexture = StyleBoxTexture.new()
	style2.texture = local_player.abilities["W"][1].Icon
	$HBoxContainer/W.add_theme_stylebox_override ("panel", style2)
	var style3 : StyleBoxTexture = StyleBoxTexture.new()
	style3.texture = local_player.abilities["E"][1].Icon
	$HBoxContainer/E.add_theme_stylebox_override ("panel", style3)
	if index != 0:
		var style4 : StyleBoxTexture = StyleBoxTexture.new()
		style4.texture = local_player.abilities["R" + str(index)][1].Icon
		$HBoxContainer/R.add_theme_stylebox_override ("panel", style4)

func _input(event):
	if event.is_action_pressed("Q"):
		apply_filter($HBoxContainer/Q, "Q")
	elif event.is_action_pressed("W"):
		apply_filter($HBoxContainer/W, "W")
	elif event.is_action_pressed("E"):
		apply_filter($HBoxContainer/E, "E")
	elif event.is_action_pressed("R"):
		apply_filter($HBoxContainer/R, "R")
	elif event.is_action_pressed("1"):
		apply_filter($HBoxContainer2/B1, "1")
	elif event.is_action_pressed("2"):
		apply_filter($HBoxContainer2/B2, "2")
	elif event.is_action_pressed("3"):
		apply_filter($HBoxContainer2/B3, "3")
	elif event.is_action_pressed("4"):
		apply_filter($HBoxContainer2/B4, "4")

func apply_filter(panel: Panel, key):
	var styleBox: StyleBoxTexture = panel.get_theme_stylebox("panel")
	var cd
	var cargas

	
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == Game.get_current_player().id:
			if key == "R":
				if player.r_index == 1:
					key = "R1"
				elif player.r_index == 2:
					key = "R2"
				else:
					return
			cd = player.abilities[key][1].cooldown
			cargas = player.abilities[key][1].charges

	var prev_color = styleBox.get("modulate_color")
	styleBox.set("modulate_color", Color(0, 0, 0))
	panel.get_child(0).set("theme_override_colors/font_color", Color(0, 0, 0))
	#panel.add_theme_stylebox_override("panel", styleBox)
	await get_tree().create_timer(cd).timeout
	styleBox.set("modulate_color", prev_color)
	panel.get_child(0).set("theme_override_colors/font_color", Color(1, 1, 1))
	#panel.add_theme_stylebox_override("panel", styleBox)
