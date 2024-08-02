extends Ability

@onready var hud = get_parent().get_parent().get_parent().get_parent().get_parent().find_child("CanvasLayer").get_child(0)
var input: String = ''
var can_shift = true
var r1_name = ''
var r2_name = ''

@rpc("call_local", "reliable")
func shiftR():
	if chara.r_index == 1:
		chara.r_index = 2
	else:
		chara.r_index = 1
	can_shift = false

func execution_ended(name_):
	if can_shift and is_multiplayer_authority():
		if chara.r_index == 1:
			if name_ == r1_name:
				shiftR.rpc()
				hud.prepare_icons(2)
		else:
			if name_ == r2_name:
				shiftR.rpc()
				hud.prepare_icons(1)

func _ready():
	chara.execution_ended.connect(execution_ended)
	input = "R" + str(chara.r_index)
	r1_name = chara.abilities["R1"][0]
	r2_name = chara.abilities["R2"][0]

func beginExecution():
	pass

func execute():
	pass

func endExecution():
	pass
	
