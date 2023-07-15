class_name CombatBody extends CharacterBody3D

@export var TARGET_NAME = "Unknown"
@export var MAX_HEALTH = 100
var curr_health = MAX_HEALTH

## Movement speed of this body.
@export var MOVE_SPEED = 5.0
## Turn speed of this body (in degrees per physics frame).
@export var TURN_SPEED = 10.0
@onready var TURN_SPEED_RADIANS = deg_to_rad(TURN_SPEED)

## The direction that this body wants to move.
var moveDirection = Vector3.ZERO

# Targeting functions

func _mouse_enter() -> void:
	CursorInputManager.mouse_entered_entity(self)
func _mouse_exit() -> void:
	CursorInputManager.mouse_left_entity(self)
func targeted() -> void:
	$Model/TargetingDecal.target()
func untargeted() -> void:
	$Model/TargetingDecal.untarget()

# Movement

func _physics_process(delta: float) -> void:
	velocity = moveDirection * MOVE_SPEED

	if velocity.length_squared() > 0:
		var y_rotation = (-$Model.global_transform.basis.z).signed_angle_to(velocity, Vector3.UP)
		if absf(y_rotation) > TURN_SPEED_RADIANS:
			y_rotation = TURN_SPEED_RADIANS * signf(y_rotation)
		$Model.rotation.y += y_rotation

	move_and_slide()
