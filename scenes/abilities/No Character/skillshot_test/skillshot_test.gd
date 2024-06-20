extends Ability

var p_scene = load("res://scenes/abilities/No Character/skillshot_test/projectile.tscn")

func _ready():
	super()

func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		execute()

func execute():
	var p: Area3D = p_scene.instantiate()
	$projectiles.add_child(p)
	p.forward_dir = chara.projectile_forward
	p.global_position = chara.projectile_spawn_pos

func endExecution():
	chara.can_cast = true
