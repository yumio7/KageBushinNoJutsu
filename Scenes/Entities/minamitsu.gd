extends CharacterBody2D

const walkSpeed: float = 50.0			# Base walking Movement speed
const walkSpeedMax: float = 200.0		# Maximum walking movement speed. Minamitsu cannot move faster than this when walking.
const jumpVelocity: float = -250.0		# Jump velocity. It is negative because in Godot up is negative y.
const fallSpeedMax: float = 250.0		# Maximum fall velocity. Minamitsu cannot fall faster than this.
const dashVelocity: float = 300.0		# Dash velocity.
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Tracks state of character for different movement behaviours
enum state {Idle = 0, Walk = 1, Jump = 2, Fall = 3, Ability = 4}	# Define enum for every state
var currentState: int = state.Idle									# Tracks the current state. By default, it is set to idle.
var walkDirection: int = 0												# Keep track of whether controls for walking are being held down

func _physics_process(delta: float) -> void:	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if Input.is_action_pressed("Ability") and (currentState == state.Fall || currentState == state.Jump):
			velocity.y = jumpVelocity
			currentState = state.Ability

	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = jumpVelocity
	
	# double jump

	var direction := Input.get_axis("Left", "Right") # left is neg, right is pos, neutral is zero
	if direction and abs(velocity.x) < walkSpeedMax:
		velocity.x += direction * walkSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, walkSpeed)

	if direction > 0:
		$AnimatedSprite2D.flip_h = false;
	elif direction < 0: 
		$AnimatedSprite2D.flip_h = true;

	if is_on_floor() and velocity.x == 0: currentState = state.Idle
	elif is_on_floor() and velocity.x != 0: currentState = state.Walk
	elif !is_on_floor() and currentState == state.Ability: pass
	elif !is_on_floor() and velocity.y >= 0: currentState = state.Fall
	elif !is_on_floor() and velocity.y < 0: currentState = state.Jump

	move_and_slide()
	$AnimatedSprite2D.play("Idle")
