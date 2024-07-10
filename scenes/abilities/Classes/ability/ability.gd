extends Node
class_name Ability

@onready var chara: BaseCharacter = get_parent().get_parent()
@onready var cooldown_timers: Node3D = Node3D.new()
@export var preview_path: NodePath = "preview"
@onready var preview: MeshInstance3D = get_node(preview_path)

@export_category("Stats")
@export var damage: float = 150
@export var mana_cost: float = 20
@export var cooldown: float = 6
@export_range(0, 10) var total_charges: int = 1

@export_category("Ui")
@export var Icon: CompressedTexture2D
@export var Name: String = "ability"
@export var Description: String = "bottom text"
# @export var Icon: Image

var charges: int = 1
var key: String = ""

func setAnimation():
	var animation_player: AnimationPlayer = chara.character_node.find_child("AnimationPlayer")
	var animation: Animation = animation_player.get_animation(key)
	if animation == null:
		animation = animation_player.get_animation("Channeling")
	if animation != null:
		var track_id = animation.find_track("..", Animation.TYPE_METHOD)
		var execute_value = { "method": &"executeAbility", "args": [self.name] }
		var end_value = { "method": &"endAbilityExecution", "args": [self.name] }
		animation.track_set_key_value(track_id, 0, execute_value)
		animation.track_set_key_value(track_id, 1, end_value)

func baseExecutionBegining():
	var cd_timer = cooldown_timers.get_child(charges - 1)
	cd_timer.start(cooldown - chara.cdr/100)
	charges -= 1
	chara.mana -= mana_cost
	chara.can_cast = false
	#Debug.sprint(get_parent().get_parent().get_parent().name + " executing " + name)
	chara.abort_oneshots()
	chara.updateTargetLocation(chara.global_position)

func _ready():
	charges = total_charges
	cooldown_timers.set_name("cooldown_timers")
	add_child(cooldown_timers)
	for i in range(total_charges):
		var new_timer = Timer.new()
		new_timer.set_name("cd_timer")
		new_timer.one_shot = true
		cooldown_timers.add_child(new_timer, true)
		new_timer.timeout.connect(_on_cd_timeout)
	preview.visible = false
	#setAnimation()
	
func beginExecution():
	if charges >= 1 and chara.mana >= mana_cost:
		baseExecutionBegining()

func execute():
	# [Insert the ability here]
	pass

func endExecution():
	# [What happens after the execution of the ability]
	pass

func _on_cd_timeout():
	charges += 1
