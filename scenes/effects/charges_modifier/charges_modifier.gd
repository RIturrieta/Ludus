extends Effect
class_name ChargesModifierEffect

var duration: float = 0
var Q: int
var W: int
var E: int
var R: int

var og_Q: int
var og_W: int
var og_E: int
var og_R: int


static func create(duration_: float, Q_: int = 0, W_: int = 0, E_: int = 0, R_: int = 0) -> ChargesModifierEffect:
	var scene = load("res://scenes/effects/charges_modifier/charges_modifier.tscn")
	var modifier: ChargesModifierEffect = scene.instantiate()
	modifier.duration = duration_
	modifier.Q = Q_
	modifier.W = W_
	modifier.E = E_
	modifier.R = R_
	return modifier

func addTimers(key, modifier):
	for i in range(modifier):
		var new_timer = Timer.new()
		new_timer.set_name("cd_timer")
		new_timer.one_shot = true
		chara.abilities[key][1].cooldown_timers.add_child(new_timer, true)
		new_timer.timeout.connect(chara.abilities[key][1]._on_cd_timeout)

func removeTimers(key, modifier):
	var running_timer_found = false
	for i in range(modifier):
		for timer: Timer in chara.abilities[key][1].cooldown_timers.get_children():
			if !timer.is_stopped():
				timer.queue_free()
				running_timer_found = true
				break
		if !running_timer_found:
			chara.abilities[key][1].cooldown_timers.get_child(0).queue_free()
			chara.abilities[key][1].charges -= 1
		running_timer_found = false
		

func _ready():
	if duration != -1:
		timer.timeout.connect(stop)
		timer.start(duration)
	og_Q = chara.abilities["Q"][1].total_charges
	og_W = chara.abilities["W"][1].total_charges
	og_E = chara.abilities["E"][1].total_charges
	og_R = chara.abilities["R"][1].total_charges
	chara.abilities["Q"][1].total_charges += Q
	chara.abilities["W"][1].total_charges += W
	chara.abilities["E"][1].total_charges += E
	chara.abilities["R"][1].total_charges += R
	chara.abilities["Q"][1].charges += Q
	chara.abilities["W"][1].charges += W
	chara.abilities["E"][1].charges += E
	chara.abilities["R"][1].charges += R
	
	if Q > 0:
		addTimers("Q", Q)
	elif Q < 0 and (og_Q + Q) > 0:
		removeTimers("Q", -Q)
		
	if W > 0:
		addTimers("W", W)
	elif W < 0 and (og_W + W) > 0:
		removeTimers("W", -W)
		
	if E > 0:
		addTimers("E", E)
	elif E < 0 and (og_E + E) > 0:
		removeTimers("E", -E)
		
	if R > 0:
		addTimers("R", R)
	elif R < 0 and (og_R + R) > 0:
		removeTimers("R", -R)

func stop():
	chara.abilities["Q"][1].total_charges = og_Q
	chara.abilities["W"][1].total_charges = og_W
	chara.abilities["E"][1].total_charges = og_E
	chara.abilities["R"][1].total_charges = og_R
	
	if Q < 0 and (og_Q + Q) > 0:
		addTimers("Q", -Q)
	elif Q > 0:
		removeTimers("Q", Q)
		
	if W < 0 and (og_W + W) > 0:
		addTimers("W", -W)
	elif W > 0:
		removeTimers("W", W)
		
	if E < 0 and (og_E + E) > 0:
		addTimers("E", -E)
	elif E > 0:
		removeTimers("E", E)
		
	if R < 0 and (og_R + R) > 0:
		addTimers("R", -R)
	elif R > 0:
		removeTimers("R", R)
	queue_free()
