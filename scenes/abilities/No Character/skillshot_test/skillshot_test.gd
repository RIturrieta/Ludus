extends Ability

var p_scene = load("res://scenes/abilities/No Character/skillshot_test/projectile.tscn")

func _ready():
	if is_multiplayer_authority():
		Debug.sprint(chara.get_parent().name)
	cd_timer.timeout.connect(_on_cd_timeout)

func beginExecution():
	if not on_cooldown and chara.mana >= mana_cost:
		baseExecutionBegining()
		execute()

func execute():
	var p: Area3D = p_scene.instantiate()
	$projectiles.add_child(p)
	p.forward_dir = chara.projectile_forward
	p.global_position = chara.projectile_spawn_pos

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	on_cooldown = false
