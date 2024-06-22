extends Ability

@export var duration: float = 5

func _ready():
	super()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()
		execute()
		#chara.character_animations.set("parameters/QShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func execute():
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player != chara:
			player.applyEffect(StopTimeEffect.create(duration))
	endExecution()

func endExecution():
	chara.can_cast = true
