extends Ability

func setAnimation():
	var animation_player: AnimationPlayer = chara.character_node.find_child("AnimationPlayer")
	var animation: Animation = animation_player.get_animation(key)
	if animation == null:
		animation = animation_player.get_animation("Channeling")
	var track_id = animation.find_track("..", Animation.TYPE_METHOD)
	var execute_value = { "method": &"executeAbility", "args": [name] }
	var end_value = { "method": &"endAbilityExecution", "args": [name] }
	animation.track_set_key_value(track_id, 0, execute_value)
	animation.track_set_key_value(track_id, 1, end_value)
	#Debug.sprint(animation.track_get_key_value(track_id, 1))

func _ready():
	super()
	
func beginExecution():
	setAnimation()
	chara.character_animations.set("parameters/" + key + "Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	#Debug.sprint(self.name + "1")
	pass

func endExecution():
	#Debug.sprint(self.name + "2")
	pass
