extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var agent = $NavigationAgent3D
var target: Vector3

@onready var camera_3d = $Path3D/PathFollow3D/Camera3D
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path_3d = $Path3D

var camera_target_pos = 0.0
@onready var animation_player = $AnimationPlayer
@onready var arrows = $PathArrows
@onready var arrows_transform = $ArrowsTransform

var locked_camera = true
@onready var camera_transform = $CameraTransform

var camera_follow_speed = 0.6
# var screen_size: Vector2

func _ready():
	# Esto se debe cambiar dsps, por obtener el tamaño desde las settings
	# screen_size = get_viewport().get_visible_rect().size
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		
	# look_at(target)
	rotation.x = 0
	rotation.y = 0
	if Input.is_action_pressed("Move"):
		target = screenPointToRay()
		if Input.is_action_just_pressed("Move"):
			target.y = 0.1
			arrows_transform.global_position = target
			animation_player.play("move_arrows")
		target.y = -0.5
		updateTargetLocation(target)
	if position.distance_to(target) > 0.5:
		var current_position = global_transform.origin
		var target_position = agent.get_next_path_position()
		var new_velocity = (target_position - current_position).normalized() * SPEED
		velocity = new_velocity
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
	#move_and_slide()

func _input(event):
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
			print("Der")
		elif position.x < 11:
			dir += Vector2(-camera_follow_speed, 0.0)
			print("Izq")
		elif screenY - position.y < 11:
			dir += Vector2(0.0, camera_follow_speed)
			print("Up")
		elif position.y < 11:
			dir += Vector2(0.0, -camera_follow_speed)
			print("Dwn")
		path_3d.global_position += Vector3(dir.x, 0.0, dir.y)