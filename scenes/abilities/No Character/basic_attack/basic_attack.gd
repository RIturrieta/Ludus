extends Ability

@onready var range_area: Area3D = $range_area
@onready var mouse_area: Area3D = $mouse_area
@onready var range_collision: CollisionShape3D = $range_area/collision
@onready var area_collision: CollisionShape3D = $mouse_area/collision
var attack_cooldown: float = 0
var attack_cooldown_offset: float = 0
var attack_ended: bool = true
var current_attack_index: int = 0
var can_cancel = true
var players_affected: Array = []
var attack_quantity: int = 1
var target_amount: int = 1
var target_player: BaseCharacter = null

func _ready():
	super()
	range_collision.shape.radius = chara.attack_range

func calculateTargetPlayer():
	var players = mouse_area.get_overlapping_bodies()
	players.erase(chara)
	if len(players) > 0:
		var min_distance: float = 999999
		var distance: float = 0
		for player in players:
			distance = player.global_position.distance_to(chara.global_position)
			if distance <= min_distance:
				min_distance = distance
				target_player = player
		updateTargetPlayer.rpc(target_player.player_info.id)
	elif target_player in range_area.get_overlapping_bodies() and !target_player.died() and chara.velocity == Vector3(0,0,0):
		target_player = target_player
	else:
		target_player = null
		updateTargetPlayer.rpc(null)

@rpc("reliable")
func updateTargetPlayer(id):
	if id == null:
		target_player = null
	else:
		var player_nodes = get_tree().get_nodes_in_group("players")
		for player in player_nodes:
			if player.player_info.id == id:
				target_player = player
				break

func calculateAffectedPlayers():
	var players = range_area.get_overlapping_bodies()
	players.erase(chara)
	players_affected = []
	for player in players:
		players_affected.append([player,chara.global_position.distance_to(player.global_position)])
	players_affected.sort_custom(func (a,b): return a[1] < b[1])
	if len(players_affected) > target_amount:
		players_affected.slice(0, target_amount)

func dealDamage():
	if target_player != null:
		for player_pair in players_affected:
			for i in range(attack_quantity):
				player_pair[0].takeAttackDamage(chara.attack_damage)
				if player_pair[0].died():
					if target_player:
						target_player = null
						chara.target = chara.global_position
						chara.updateTargetLocation(chara.target)

func stopAttack():
	target_player = null
	attack_ended = true
	chara.can_move = true
	attack_cooldown = 0
	attack_cooldown_offset = 0
	current_attack_index = 0
	for i in range(chara.total_attack_animations):
		chara.character_animations.set(str("parameters/BasicAttack", i + 1,"/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func _physics_process(delta):
	if chara.can_act:
		mouse_area.global_position = chara.mouse_pos
		attack_cooldown = max(0, attack_cooldown - delta)
		attack_cooldown_offset = max(0, attack_cooldown_offset - delta)
		if attack_cooldown == 0 && attack_cooldown_offset == 0 && !attack_ended:
			attack_ended = true
		
		if is_multiplayer_authority():
			if target_player == null:
				if Input.is_action_just_pressed("Move"):
					calculateTargetPlayer()
			else:
				if Input.is_action_pressed("Move"):
					calculateTargetPlayer()
		
		if target_player != null and target_player.died():
			target_player = null
		if !attack_ended and target_player == null and can_cancel:
			stopAttack()
		
		if target_player != null and target_player != chara:
			if target_player in range_area.get_overlapping_bodies():
				if !chara.is_dashing:
					chara.target = chara.global_position
					chara.updateTargetLocation(chara.target)
				if attack_ended:
					calculateAffectedPlayers()
					beginExecution()
			else:
				if !chara.is_dashing:
					chara.target = target_player.global_position
					chara.updateTargetLocation(chara.target)
	
func beginExecution():
	calculateAffectedPlayers()
	if len(players_affected) > 0:
		if target_player == null:
			target_player = players_affected[0][0]
		if !can_cancel:
			chara.can_move = false
		attack_cooldown_offset = chara.attack_duration / chara.attack_speed
		attack_ended = false
		chara.character_node.look_at(target_player.global_position, Vector3.UP)
		chara.character_animations.set(str("parameters/BasicAttack", current_attack_index + 1,"/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	can_cancel = false
	chara.can_move = false
	attack_cooldown = attack_cooldown_offset
	current_attack_index = (current_attack_index + 1) % chara.total_attack_animations
	dealDamage()
	
func endExecution():
	can_cancel = true
	chara.can_move = true
