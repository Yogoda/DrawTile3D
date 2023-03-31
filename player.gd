extends CharacterBody3D

@export var speed_slow: = 5.0
@export var speed_fast: = 15.0
@export var jump_velocity: = 4.5

var speed: = speed_slow

const MOUSE_FACTOR = 2000
const MOUSE_SENSITIVITY = 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _unhandled_input(event):
	
	#rotate camera
	if event is InputEventMouseMotion:
			
		var rot_x = event.relative.y / MOUSE_FACTOR * MOUSE_SENSITIVITY
		var rot_y = event.relative.x / MOUSE_FACTOR * MOUSE_SENSITIVITY
		
		rotation.y -= rot_y
		camera.rotation.x -= rot_x
		
	elif event is InputEventKey:
		
		if event.keycode == KEY_ESCAPE:
			get_tree().quit();
			
		elif event.keycode == KEY_SHIFT:
			if event.pressed:
				speed = speed_fast
			else:
				speed = speed_slow

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
