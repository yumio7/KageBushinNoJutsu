extends CharacterBody2D
# Boss enemy.
# Tracks the player and fires danmaku patterns.


const flightSpeed: float = 200				# Speed seija will fly normally
const flightSpeedFlee: float = 500			# Speed seija will fly after being hit and fleeing to the next area
const projectileSpeed: float = 50 			# Projectile speed
const projectileMelonSpeed: float = 100		# Watermelon speed

@export var movementGroupsArray: Array[Node2D]	# Designates an array of node2Ds in which seija will move to after being hit
@export var checkpointFloorArray: Array[Node2D]	# Designates an array of node2Ds in which the checkpoint will update
@export var limitCeilingArray: Array[Node2D]	# Designates an array of node2Ds in which there will be a ceiling preventing player progress before damaging seija
@export var mirroredForm: Node2D				# Designates the mirrored form of seija that will fire danmaku alongside her

enum state {Idle = 0, Moving = 1, Firing = 2, Damaged = 3, Fleeing = 4, Dead = 5, Paused = 6}	# State machine
var currentState = state.Paused	# Current state of the character
var phaseIndex: int = 0	# Tracks current phase. Increases when damaged. ALSO WORKS AS A SORT OF HP COUNTER.

func _physics_process(delta: float) -> void:
	
	# Always relocate the mirroredForm to the same relative position on the opposite side of the mirror
	mirroredForm.position = position - Vector2(position.x - 480, 0)

	# General behaviour. Idle>Moving>Firing>Idle. Can be damaged in any one of these states.
	# Damaged behaviour. Damaged>Fleeing>Idle. 

	# State machine. Depending on the currentState, run a different function with different movement behaviour
	match currentState:
		0: stateIdle()
		1: stateMoving()
		2: stateFiring()
		3: stateDamaged()
		4: stateFleeing()
		5: stateDead()
		6: statePaused()

	move_and_slide()

# State functions
func stateIdle():
	pass

func stateMoving():
	pass

func stateFiring():
	pass

func stateDamaged():
	pass

func stateFleeing():
	pass

func stateDead():
	pass

func statePaused():
	$AnimatedSprite2D.play("Idle")