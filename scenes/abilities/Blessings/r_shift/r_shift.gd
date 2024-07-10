extends Ability

var input: String = ''
var can_shift = true
var r1_name = ''
var r2_name = ''

#func _physics_process(delta):
	#print(chara.abilities[input][1].charges)
	#if can_shift and Input.is_action_just_pressed("R") and is_multiplayer_authority():
		#print(chara.abilities[input][1].charges)
		#if chara.abilities[input][1].charges >= 1 and chara.can_act and chara.can_cast:
			#shiftR.rpc()
			
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
		else:
			if name_ == r2_name:
				shiftR.rpc()

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
	
