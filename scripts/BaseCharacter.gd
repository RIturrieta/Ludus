class_name BaseCharacter
extends CharacterBody3D

const SPEED = 4.5
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var agent = $NavigationAgent3D
var target: Vector3

@onready var camera_3d = $Path3D/PathFollow3D/Camera3D
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path_3d = $Path3D

var camera_target_pos = 0.0
@onready var animation_player = $AllAnimationPlayer
@onready var arrows = $PathArrows
@onready var arrows_transform = $ArrowsTransform

var locked_camera = true
@onready var camera_transform = $CameraTransform

@onready var label_3d = $Label3D

@export var character_node: Node3D
var character_animations: AnimationTree
var prev_lookat = global_transform.basis.z

var camera_follow_speed = 0.6
# var screen_size: Vector2

@onready var projectile_ray: RayCast3D = $ProjectileRay
@onready var projectile_spawn: Node3D = $ProjectileRay/SpawnPoint

func _ready():
	label_3d.global_transform = character_node.get_node("HealthMarker").global_transform
	character_animations = character_node.get_node("AnimationTree")
	
	for key in abilities.keys():
		loadAbility(key)
	
func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
	#	velocity.y -= gravity * delta
		
	if character_animations:
		var blend_val = min(velocity.length(), 1)
		character_animations.set("parameters/IdleWalkBlend/blend_amount", blend_val)
		
	if target:
		if (Vector3(global_transform.origin.x, 0.0, global_transform.origin.z) \
		- Vector3(target.x, 0.0, target.z)).length() > 0.5 and velocity.length() != 0:
			var new_look = lerp(prev_lookat, (global_transform.origin + velocity), 0.3)
			prev_lookat = new_look
			character_node.look_at(new_look, Vector3.UP)
		#rotation.x = 0
		#rotation.y = 0
	#rotation.x = 0
	#rotation.y = 0
	if is_multiplayer_authority():
		if Input.is_action_pressed("Move"):
			target = screenPointToRay()
			if Input.is_action_just_pressed("Move"):
				target.y = 0.1
				arrows_transform.global_position = target
				animation_player.play("move_arrows")
			target.y = -0.5
			updateTargetLocation(target)
		if velocity.length() > 0.0:
			sendData.rpc(global_position, velocity, target)
		if !agent.is_navigation_finished():
			var current_position = global_transform.origin
			var target_position = agent.get_next_path_position()
			var new_velocity = (target_position - current_position).normalized() * SPEED
			velocity = new_velocity
		else:
			velocity = Vector3(0.0, 0.0, 0.0)
			sendData.rpc(global_position, velocity, target)
	move_and_slide()
	if Input.is_action_just_pressed("Release Camera"):
		if locked_camera:
			locked_camera = false
			path_3d.top_level = true
			camera_transform.update_position = false
			camera_transform.top_level = true
		else:
			locked_camera = true
			path_3d.top_level = false
			camera_transform.global_position = global_transform.origin
			camera_transform.update_position = true
			camera_transform.top_level = false
			
	if Input.is_action_pressed("Center Camera") and !locked_camera:
		print("Centering")
		locked_camera = true
		path_3d.top_level = false
		camera_transform.global_position = global_transform.origin
		camera_transform.update_position = true
		camera_transform.top_level = false
	
		locked_camera = false
		path_3d.top_level = true
		camera_transform.update_position = false
		camera_transform.top_level = true
	
	path_follow_3d.progress_ratio = lerp(path_follow_3d.progress_ratio, camera_target_pos, 0.2)
	
	var projectile_ray_target = screenPointToRay()
	projectile_ray.look_at(projectile_ray_target, Vector3(0,2,0))
	projectile_ray.rotation.x = 0
	executeAbilities()

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			var ratio = path_follow_3d.progress_ratio
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and ratio < 1:
				camera_target_pos = min(ratio + 0.1, 1.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and ratio > 0:
				camera_target_pos = max(ratio - 0.1, 0.0)
			   # Mouse in viewport coordinates.
		elif event is InputEventMouseMotion:
			moveCameraByCursor(event.position)
	
func screenPointToRay():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera_3d.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera_3d.project_ray_normal(mouse_position) * 2000
	var args = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var ray_array = space_state.intersect_ray(args)
	if ray_array.has("position"):
		return ray_array["position"]
	return Vector3()
	
func updateTargetLocation(target):
	agent.target_position = target
	
func moveCameraByCursor(position: Vector2):
	if !locked_camera:
		var screen_size = get_viewport().get_visible_rect().size
		var screenX = screen_size.x
		var screenY = screen_size.y
		var dir = Vector2(0.0, 0.0)
		if screenX - position.x < 11:
			dir += Vector2(camera_follow_speed, 0.0)
		elif position.x < 11:
			dir += Vector2(-camera_follow_speed, 0.0)
		elif screenY - position.y < 11:
			dir += Vector2(0.0, camera_follow_speed)
		elif position.y < 11:
			dir += Vector2(0.0, -camera_follow_speed)
		path_3d.global_position += Vector3(dir.x, 0.0, dir.y)


# ========== ABILITIES ========== #

# Key: String | Value: Node or String
# An ability can be added by changing a null value for the name of the ability.
# When the ability is loaded, its value in the dictionary will change to the 
# node of the ability instead of its name.
@onready var abilities: Dictionary = {
	"Q": "skillshot_test",
	"W": "base_ability",
	"E": null,
	"R": null,
	"1": null,
	"2": null, 
	"3": null,
	"4": null,
}

# Adds the ability assigned to a certain key as a child of the character and
# adds the node to the dictionary
func loadAbility(key: String):
	if abilities.has(key) and abilities[key] != null:
		var scene = load("res://scenes/abilities/" + abilities[key] + "/" + abilities[key] + ".tscn")
		var sceneNode = scene.instantiate()
		abilities[key] = sceneNode
		$Abilities.add_child(sceneNode)
		
# Adds a new ability to the character and loads it
func addAbility(ability_name: String, key: String):
	if abilities[key] != null:
		abilities[key].queue_free()
	abilities[key] = ability_name
	loadAbility(key)

# Executes abilities based on the input
func executeAbilities():
	for key in abilities.keys():
		if Input.is_action_just_pressed(key) and abilities[key] != null:
			var dir = screenPointToRay()
			abilities[key].execute(self, dir)


# ========== MULTIPLAYER ========== #

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	label_3d.text = str(player_data.name) + "\nTeam" +str(player_data.role)
	set_multiplayer_authority(player_data.id)
	if is_multiplayer_authority():
		camera_3d.current = true
	
@rpc
func sendData(pos: Vector3, vel: Vector3, targ: Vector3):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	target = targ
