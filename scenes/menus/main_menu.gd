extends Control

@onready var play_button: Button = %Play
@onready var credits_button: Button = %Credits
@onready var exit_button: Button = %Exit

@onready var menu: Control = %MenuButtons
@onready var lobby: Control = %Lobby
@onready var credits: Control = %CreditsMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	lobby.returned.connect(return_to_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func return_to_menu():
	menu.visible = true
	lobby.visible = false

func _on_play_pressed():
	menu.visible = false
	lobby.visible = true

func _on_exit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	menu.visible = false
	credits.visible = true

func _on_exit_credits_pressed():
	menu.visible = true
	credits.visible = false
