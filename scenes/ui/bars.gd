extends Control

@onready var meter = %Meter
@onready var chara: BaseCharacter = get_parent().get_parent()

func update_size():
	meter.size.x = 200 * 6000 / chara.max_hp

func _ready():
	update_size()
