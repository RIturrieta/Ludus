extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label3D = $LabelContainer/Label3D
var type: String = "damage"
var value: float = 0
var max_offset = 1.25


func _ready():
	var random_offset = Vector3(randf_range(-max_offset, max_offset), 
								randf_range(0, max_offset), 
								randf_range(-max_offset, max_offset))
	position = random_offset
	if value < 10:
		label.text = str(snappedf(value, 0.1))
	else:
		label.text = str(roundf(value))
	animation_player.play(type)

func disappear():
	queue_free()

