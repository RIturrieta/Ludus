extends MarginContainer




@onready var user = %User
@onready var host = %Host
@onready var join = %Join


@onready var ip = %IP
@onready var back_join: Button = %BackJoin
@onready var confirm_join: Button = %ConfirmJoin

@onready var role_a: Button = %RoleA
@onready var role_b: Button = %RoleB
@onready var role_c: Button = %RoleC
@onready var role_d: Button = %RoleD

@onready var char_1: Button = %Char1
@onready var char_2: Button = %Char2
@onready var char_3: Button = %Char3
@onready var char_4: Button = %Char4
@onready var char_5: Button = %Char5

@onready var back_ready: Button = %BackReady
@onready var ready_toggle: Button = %Ready

@onready var menus: MarginContainer = %Menus

@onready var start_menu = %StartMenu
@onready var join_menu = %JoinMenu
@onready var ready_menu = %ReadyMenu

@onready var players = %Players

@onready var start_timer: Timer = $StartTimer

@onready var time_container: HBoxContainer = %TimeContainer
@onready var time: Label = %Time


@export var lobby_player_scene: PackedScene

# { id: true }
var status = { 1 : false }

var _menu_stack: Array[Control] = []

signal returned()

func _ready():
	
	if Game.multiplayer_test:
		get_tree().change_scene_to_file("res://scenes/lobby_test.tscn")
		return
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	Game.player_updated.connect(func(_id) : _check_ready())
	Game.player_updated.connect(func(_id) : _update_buttons())
	Game.players_updated.connect(_check_ready)
	
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	
	confirm_join.pressed.connect(_on_confirm_join_pressed)
	
	back_join.pressed.connect(_back_menu)
	back_ready.pressed.connect(_back_menu)
	
	role_a.pressed.connect(func(): Game.set_current_player_role_and_slot(Statics.Role.TEAM_A, 1))
	role_b.pressed.connect(func(): Game.set_current_player_role_and_slot(Statics.Role.TEAM_B, 1))
	role_c.pressed.connect(func(): Game.set_current_player_role_and_slot(Statics.Role.TEAM_A, 2))
	role_d.pressed.connect(func(): Game.set_current_player_role_and_slot(Statics.Role.TEAM_B, 2))

	char_1.pressed.connect(func(): Game.set_current_player_character(Statics.Character.CHAR1))
	char_2.pressed.connect(func(): Game.set_current_player_character(Statics.Character.CHAR2))
	char_3.pressed.connect(func(): Game.set_current_player_character(Statics.Character.CHAR3))
	char_4.pressed.connect(func(): Game.set_current_player_character(Statics.Character.CHAR4))
	char_5.pressed.connect(func(): Game.set_current_player_character(Statics.Character.CHAR5))
	
	ready_toggle.pressed.connect(_on_ready_toggled)
	
	start_timer.timeout.connect(_on_start_timer_timeout)
	
	ready_toggle.disabled = true
	time_container.hide()

	_go_to_menu(start_menu)
	
	user.text = OS.get_environment("USERNAME") + (str(randi() % 1000) if Engine.is_editor_hint()
 else "")
	
	Game.upnp_completed.connect(_on_upnp_completed, 1)


func _process(_delta: float) -> void:
	if !start_timer.is_stopped():
		time.text = str(ceil(start_timer.time_left))


func _on_upnp_completed(_status) -> void:
	#print(_status)
	#if _status == OK:
		#Debug.sprint("Port Opened", 5)
	#else:
		#Debug.sprint("Port Error", 5)
	pass


func _on_host_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	
	var err = peer.create_server(Statics.PORT, Statics.MAX_CLIENTS)
	if err:
		#Debug.sprint("Host Error: %d" %err)
		return
	
	multiplayer.multiplayer_peer = peer
	
	var player = Statics.PlayerData.new(multiplayer.get_unique_id(), user.text, 0)
	_add_player(player)
	
	_go_to_menu(ready_menu)


func _on_join_pressed() -> void:
	_go_to_menu(join_menu)


func _on_confirm_join_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip.text, Statics.PORT)
	if err:
		#Debug.sprint("Host Error: %d" %err)
		return
	print("pasastes")
	multiplayer.multiplayer_peer = peer
	
	var player = Statics.PlayerData.new(multiplayer.get_unique_id(), user.text, 0)
	_add_player(player)
	
	_go_to_menu(ready_menu)


func _on_connected_to_server() -> void:
	#Debug.sprint("connected_to_server")
	pass


func _on_connection_failed() -> void:
	#Debug.sprint("connection_failed")
	pass


func _on_peer_connected(id: int) -> void:
	#Debug.sprint("peer_connected %d" % id)
	
	send_info.rpc_id(id, Game.get_current_player().to_dict())
	var _local_id = multiplayer.get_unique_id()
	if multiplayer.is_server():
		for player_id in status:
			set_player_ready.rpc_id(id, player_id, status[player_id])
		status[id] = false


func _on_peer_disconnected(id: int) -> void:
	#Debug.sprint("peer_disconnected %d" % id)
	_remove_player(id)
	if multiplayer.is_server():
		starting_game.rpc(false)
	
	# Server closed connection
	if id == 1:
		_back_menu()


func _on_server_disconnected() -> void:
	#Debug.sprint("server_disconnected")
	pass


func _add_player(player: Statics.PlayerData) -> void:
	Game.add_player(player)
	
	var lobby_player = lobby_player_scene.instantiate() as UILobbyPlayer
	players.add_child(lobby_player)
	lobby_player.setup(player)


func _remove_player(id: int):
	var lobby_player = players.find_child(str(id), true, false)
	players.remove_child(lobby_player)
	lobby_player.queue_free()
	status.erase(id)
	Game.remove_player(id)




@rpc("any_peer", "reliable")
func send_info(info_dict: Dictionary) -> void:
	var player = Statics.PlayerData.new(info_dict.id, info_dict.name, info_dict.role)
	_add_player(player)


func _paint_ready(id: int) -> void:
	for child in players.get_children():
		if child.name == str(id):
			child.modulate = Color.GREEN_YELLOW


func _on_ready_toggled() -> void:
	player_ready.rpc_id(1, multiplayer.get_unique_id())


@rpc("reliable", "any_peer", "call_local")
func player_ready(id: int):
	if multiplayer.is_server():
		status[id] = !status[id]
		set_player_ready.rpc(id, status[id])
		var all_ok = true
		for ok in status.values():
			all_ok = all_ok and ok
		if all_ok:
			starting_game.rpc(true)
		else:
			starting_game.rpc(false)


@rpc("reliable", "any_peer", "call_local")
func set_player_ready(id: int, value: bool):
	for child in players.get_children():
		var player = child as UILobbyPlayer
		if player.player_id == id:
			player.set_ready(value)


@rpc("any_peer", "call_local", "reliable")
func starting_game(value: bool):
	role_a.disabled = value
	role_b.disabled = value
	role_c.disabled = value
	role_d.disabled = value
	back_ready.disabled = value
	time_container.visible = value
	if value:
		start_timer.start()
	else:
		start_timer.stop()


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")



func _check_ready() -> void:
	var roles = []
	for player in Game.players:
		if not player.role in roles and player.role != Statics.Role.NONE:
			roles.push_back(player.role)
	ready_toggle.disabled = roles.size() != Statics.Role.size() - 1
	for player in Game.players:
		if player.character == Statics.Character.NONE:
			ready_toggle.disabled = true
			break

func _update_buttons() -> void:
	var buttons = [[role_a, role_c], [role_b, role_d]]
	var names = ["Team A", "Team B"]
	for teams in buttons:
		for i in teams:
			i.disabled = false
			i.text = names[buttons.find(teams)] + str("-",teams.find(i) + 1)
	var team
	var slot
	for player in Game.players:
		if player.role != Statics.Role.NONE:
			team = player.role - 1
			slot = player.slot - 1
			buttons[team][slot].disabled = true
			buttons[team][slot].text = player.name

func _disconnect():
	multiplayer.multiplayer_peer.close()
	
	for player in players.get_children():
		players.remove_child(player)
		player.queue_free()
	
	ready_toggle.disabled = true
	status = { 1 : false }
	Game.players = []


func _on_start_timer_timeout() -> void:
	if multiplayer.is_server():
		start_game.rpc()


func _hide_menus():
	for child in menus.get_children():
		child.hide()


func _go_to_menu(menu: Control) -> void:
	_hide_menus()
	_menu_stack.push_back(menu)
	menu.show()
	# if the menu is the ready menu, move anchor to center left
	if menu == ready_menu:
		#print("aaaa")
		set_anchors_preset(LayoutPreset.PRESET_CENTER_LEFT)
	else:
		#print("b")
		set_anchors_preset(LayoutPreset.PRESET_CENTER_LEFT)
	#print(anchors_preset)


func _back_menu() -> void:
	_hide_menus()
	_menu_stack.pop_back()
	var menu = _menu_stack.back()
	if menu:
		menu.show()
		set_anchors_preset(LayoutPreset.PRESET_FULL_RECT)
	_disconnect()


func _back_to_first_menu() -> void:
	var first = _menu_stack.front()
	_menu_stack.clear()
	if first:
		_menu_stack.push_back(first)
		first.show()
	if Game.is_online():
		_disconnect()


func _on_exit_pressed():
	returned.emit()
