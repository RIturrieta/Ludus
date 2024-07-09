extends Control

@onready var name_label: Label = %Name
@onready var cooldown_label: Label = %Cooldown
@onready var description_label: Label = %Description
var blessing_name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func loadBlessing(ability_name: String):
	blessing_name = ability_name
	var path = "res://scenes/abilities/" + get_parent().name + "/" + ability_name + "/" + ability_name + ".tscn"
	if !ResourceLoader.exists(path):
		path = "res://scenes/abilities/" + "Blessings" + "/" + ability_name + "/" + ability_name + ".tscn"
		if !ResourceLoader.exists(path):
			path = "res://scenes/abilities/" + "No Character" + "/" + ability_name + "/" + ability_name + ".tscn"
			if !ResourceLoader.exists(path):
				path = "res://scenes/abilities/No Character/base_ability/base_ability.tscn"
	var ability = load(path)
	ability = ability.instantiate()
	name_label.text = ability.Name
	if ability.cooldown > 0:
		cooldown_label.text = "Cooldown: " + str(ability.cooldown)
	else:
		cooldown_label.text = "Passive"
	description_label.text = ability.Description
	ability.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
