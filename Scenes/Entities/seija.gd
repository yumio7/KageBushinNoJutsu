extends CharacterBody2D
# Boss enemy.
# Tracks the player and fires danmaku patterns.

const flightSpeed: float = 75				# Speed seija will fly normally
const hitKnockback: float = 100				# Speed seija is knocked back when hit
const flightSpeedFlee: float = 300			# Speed seija will fly after being hit and fleeing to the next area
const projectileSpeed: float = 50 			# Projectile speed
const projectileMelonSpeed: float = 100		# Watermelon speed

@export var movementGroup: Node2D				# Designates container of node2Ds in which seija will move to after being hit
@export var checkpointGroup: Node2D				# Designates container of node2Ds in which the checkpoint will update
@export var limitCeilingGroup: Node2D			# Designates container of node2Ds in which there will be a ceiling preventing player progress before damaging seija
@export var mirroredForm: Node2D				# Designates the mirrored form of seija that will fire danmaku alongside her
@export var targetCharacter: CharacterBody2D	# Designates the targeted character

enum state {Idle = 0, Firing = 1, Damaged = 2, Fleeing1 = 3, Dead = 4, Paused = 5}	# State machine
var currentState = state.Idle	# Current state of the character
var currentMovementNode			# Tracks the current movement group that seija uses to navigate around
var phaseIndex: int = 0			# Tracks current phase. Increases when damaged. ALSO WORKS AS A SORT OF HP COUNTER.
var firingAmmo: int = 3			# Current instances bullets can be fired before returning to idle state

var basicProjectileScene: PackedScene = preload("res://Scenes/Entities/seija_basic_projectile.tscn")

func _ready() -> void:
	$Timers/IdleTimer.start()
	currentMovementNode = movementGroup.get_child(phaseIndex)

func _physics_process(delta: float) -> void:
	
	# Always relocate the mirroredForm to the same relative position on the opposite side of the mirror
	mirroredForm.position = position

	# General behaviour. Idle>Firing>Idle. Can be damaged in any one of these states.
	# Damaged behaviour. Damaged>Fleeing1-2>Idle. 

	# State machine. Depending on the currentState, run a different function with different movement behaviour
	match currentState:
		0: stateIdle()
		1: stateFiring()
		2: stateDamaged()
		3: stateFleeing()
		4: stateDead()
		5: statePaused()

	move_and_slide()

# State functions
func stateIdle():
	$AnimatedSprite2D.play("Idle")
	if $Timers/IdleTimer.is_stopped(): $Timers/IdleTimer.start()
	moveToCurrentNode()
	
func stateFiring():
	$AnimatedSprite2D.play("Idle")
	moveToCurrentNode()


func stateDamaged():
	$AnimatedSprite2D.play("Idle")


func stateFleeing():
	pass

func stateDead():
	pass

func statePaused():
	$AnimatedSprite2D.play("Idle")
	moveToCurrentNode()

# Only count the hit if seija is in the idle, or attack state
func hitByPlayer():
	match currentState:
		0, 1:
			phaseIndex += 1
			if phaseIndex < movementGroup.get_child_count(): currentMovementNode = movementGroup.get_child(phaseIndex)
			currentState = state.Damaged
			$Timers/IdleTimer.stop()
			$Timers/FiringDelay.stop()
			$Timers/DamagedTimer.start()

# Seija tries to move towards movement node
func moveToCurrentNode():
	if position.distance_to(currentMovementNode.position) > 15:
		velocity = position.direction_to(currentMovementNode.position) * flightSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, flightSpeed)
		velocity.y = move_toward(velocity.y, 0, flightSpeed)

func _on_idle_timer_timeout() -> void:
	currentState = state.Firing

	# Give different firing ammo depending on the phase
	match phaseIndex:
		0:
			firingAmmo = 3
			$Timers/FiringDelay.wait_time = 1
		1: 
			firingAmmo = 5
			$Timers/FiringDelay.wait_time = 1
		2: 
			firingAmmo = 5
			$Timers/FiringDelay.wait_time = .5
		3: 
			firingAmmo = 2
			$Timers/FiringDelay.wait_time = 1
		4: 
			firingAmmo = 7
			$Timers/FiringDelay.wait_time = .3
		5: 
			firingAmmo = 5
			$Timers/FiringDelay.wait_time = .5
	$Timers/FiringDelay.start()

func _on_damaged_timer_timeout() -> void:
	currentState = state.Fleeing1

# Reduce ammo and fire depending on current phase
func _on_firing_delay_timeout() -> void:
	firingAmmo -= 1

	# Match the phase to the desired firing pattern
	match phaseIndex:
		0: firePattern0()

	# Return to idle
	if firingAmmo <= 0:
		$Timers/FiringDelay.stop()
		$Timers/IdleTimer.start()
		currentState = state.Idle

# FIRING PATTERNS
func firePattern0():
	
	var baseFiringDirection = Vector2(0, 1).rotated(deg_to_rad(20 * firingAmmo))
	for i in 3:
		fireBullet(baseFiringDirection.rotated(deg_to_rad(-60*i)), position, basicProjectileScene)
		fireBullet(baseFiringDirection.rotated(deg_to_rad(-60*i)) * -1, mirroredForm.global_position, basicProjectileScene)


# General bullet firing function
# direction is the base firing direction vector
# amount arg is amount of bullets fired at once
# angle is the angle deviation between bullets in degrees
# type is the type of bullet being fired
func fireBullet(bulletDirection: Vector2, bulletPosition: Vector2, bulletType: PackedScene):
	var newBullet = bulletType.instantiate()
	newBullet.bulletVelocity = bulletDirection * projectileSpeed
	$"..".add_child(newBullet)
	newBullet.position = bulletPosition

