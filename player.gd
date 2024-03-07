extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var pivot = $TwistPivot
@onready var springarm =  $TwistPivot/SpringArm3D
@onready var body = $Body
@export var sens = 0.01

var moving = false
var doublejump = true
var sprinting = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#func has_not_doublejumped():
	#return doublejumped

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		pivot.rotate_y(deg_to_rad(-event.relative.x * sens))
		springarm.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	if Input.is_action_just_pressed("sprint"):
		sprinting = true
		
	if Input.is_action_just_released("sprint"):
		sprinting = false
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if !doublejump and is_on_floor():
		doublejump = true
	#if is_on_floor() and !has_not_doublejumped():
		#doublejumped = false
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or doublejump):
		velocity.y = JUMP_VELOCITY
		if !is_on_floor():
			doublejump = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("moveleft", "moveright", "moveforward", "movebackward")
	var direction = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if sprinting:
			velocity.x = direction.x * SPEED * 2
			velocity.z = direction.z * SPEED * 2
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if velocity != Vector3.ZERO and direction:
		var camera_quaternion = Quaternion(pivot.basis.orthonormalized())
		#var direction_quaternion = Quaternion(pivot.basis.orthonormalized()) * Vector3(input_dir.x, 0, input_dir.y)
		var body_quaternion = Quaternion(body.basis.orthonormalized())
		
		#var slerp_quaternion = body_quaternion.slerp(direction_quaternion, delta)
		var slerp_quaternion = body_quaternion.slerp(camera_quaternion, delta)
		body.basis = Basis(slerp_quaternion)
		#body.look_at(pivot.basis * Vector3(input_dir.x, 0, input_dir.y))

	move_and_slide()
