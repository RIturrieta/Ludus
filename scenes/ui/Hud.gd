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
	var styleBox: StyleBoxFlat = panel.get_theme_stylebox("panel")
	var cd
	var cargas

	
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == Game.get_current_player().id:
			cd = player.abilities[key][1].cooldown
			cargas = player.abilities[key][1].charges

	
	styleBox.set("bg_color", Color(0, 0, 0))
	panel.get_child(0).set("theme_override_colors/font_color", Color(0, 0, 0))
	panel.add_theme_stylebox_override("panel", styleBox)
	await get_tree().create_timer(cd).timeout
	styleBox.set("bg_color", Color(0.22, 0.22, 0.22))
	panel.get_child(0).set("theme_override_colors/font_color", Color(1, 1, 1))
	panel.add_theme_stylebox_override("panel", styleBox)
