class_name CombatBody extends CharacterBody3D

enum CombatTeam {UNKNOWN, FRIEND, ENEMY}

signal health_changed(new_health: float, max_health: float)

@export var TARGET_NAME = "Unknown"
@export var MAX_HEALTH = 100.0
@export var TEAM: CombatTeam = CombatTeam.UNKNOWN
var curr_health = MAX_HEALTH

## Movement speed of this body.
@export var MOVE_SPEED = 5.0
## Turn speed of this body (in degrees per physics frame).
@export var TURN_SPEED = 10.0
@onready var TURN_SPEED_RADIANS = deg_to_rad(TURN_SPEED)

## The direction that this body wants to move.
var moveDirection = Vector3.ZERO
var curr_target: CombatBody = null

# Targeting functions

func _mouse_enter() -> void:
	CursorInputManager.mouse_entered_entity(self)
func _mouse_exit() -> void:
	CursorInputManager.mouse_left_entity(self)
func targeted() -> void:
	$Model/TargetingDecal.target()
func untargeted() -> void:
	$Model/TargetingDecal.untarget()


func alter_health(delta: float) -> void:
	curr_health += delta
	if curr_health > MAX_HEALTH:
		curr_health = MAX_HEALTH
	elif curr_health < 0:
		curr_health = 0
	health_changed.emit(curr_health, MAX_HEALTH)

# Movement

func _physics_process(delta: float) -> void:
	velocity = moveDirection * MOVE_SPEED

	if velocity.length_squared() > 0:
		var y_rotation = (-$Model.global_transform.basis.z).signed_angle_to(velocity, Vector3.UP)
		if absf(y_rotation) > TURN_SPEED_RADIANS:
			y_rotation = TURN_SPEED_RADIANS * signf(y_rotation)
		$Model.rotation.y += y_rotation

	move_and_slide()
