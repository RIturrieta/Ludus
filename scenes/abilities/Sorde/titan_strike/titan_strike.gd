extends Ability

var range: float = 8

var target_player: BaseCharacter

var jumping: bool = false

func _ready():
	cd_timer.timeout.connect(_on_cd_timeout)

func _physics_process(delta):
	if jumping:
		chara.updateTargetLocation(target_player.global_position)

func beginExecution():
	if chara.is_multiplayer_authority():
		if chara.is_target_player(chara.mouse_pos):
			target_player = chara.get_target_player(chara.mouse_pos)
			if chara.global_position.distance_to(target_player.global_position) < range:
				if target_player != chara and not on_cooldown and chara.mana >= mana_cost:
					#Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
					#on_cooldown = true
					#cd_timer.start()
					#chara.mana -= mana_cost
					beginExecutionRemote.rpc(target_player.player_info.id)

@rpc("any_peer", "call_local", "reliable")
func beginExecutionRemote(id: int):
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.player_info.id == id:
			target_player = player
			break
	baseExecutionBegining()
	chara.agent.navigation_layers = 0b00000010
	chara.character_animations.set("parameters/R1Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	chara.target_player = null
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = true
	jumping = true
	chara.dash(18 * 33.333)
	chara.updateTargetLocation(target_player.global_position)

func endExecution():
	jumping = false
	chara.clearDash()
	var hitbox = chara.get_node("HitBox")
	if hitbox:
		hitbox.disabled = false
	chara.agent.navigation_layers = 0b00000001
	target_player.takeAbilityDamage(damage, chara.spell_power)
	target_player.modifyStats(4, 1, 0, -25, 0, 1, 1, 0, 1)
	target_player = null

func _on_cd_timeout():
	on_cooldown = false
