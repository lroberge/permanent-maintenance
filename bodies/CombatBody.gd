class_name CombatBody extends CharacterBody3D

enum CombatTeam {UNKNOWN, FRIEND, ENEMY}

static var AllCombatants: Array[CombatBody] = []

signal health_changed(new_health: float, max_health: float)

@export var TARGET_NAME = "Unknown"
@export var MAX_HEALTH = 100.0
@export var TEAM: CombatTeam = CombatTeam.UNKNOWN
var curr_health = MAX_HEALTH
var is_dead:
	get:
		if curr_health <= 0: return true
		else: return false

const REGEN_AMOUNT = 5.0 / 60
var can_regen_health = false
@onready var regen_timer: Timer = get_node_or_null("RegenTimer")

## Movement speed of this body.
@export var MOVE_SPEED = 5.0
## Turn speed of this body (in degrees per physics frame).
@export var TURN_SPEED = 10.0
@onready var TURN_SPEED_RADIANS = deg_to_rad(TURN_SPEED)

## The direction that this body wants to move.
var moveDirection = Vector3.ZERO
var faceDirection = Vector3.ZERO
var curr_target: CombatBody = null

func _ready():
	AllCombatants.append(self)
	if regen_timer != null:
		regen_timer.timeout.connect(regen_debounce)

func _process(delta: float) -> void:
	if can_regen_health:
		alter_health(REGEN_AMOUNT)

# Targeting functions

func _mouse_enter() -> void:
	CursorInputManager.mouse_entered_entity(self)
func _mouse_exit() -> void:
	CursorInputManager.mouse_left_entity(self)
func targeted() -> void:
	$Model/TargetingDecal.target()
func untargeted() -> void:
	$Model/TargetingDecal.untarget()

func heal_percent(pct: float) -> void:
	return alter_health(MAX_HEALTH * pct)

func alter_health(delta: float) -> void:
	if delta < 0 and regen_timer != null:
		can_regen_health = false
		$RegenTimer.stop()
		$RegenTimer.start()
	curr_health += delta
	if curr_health > MAX_HEALTH:
		curr_health = MAX_HEALTH
	elif curr_health < 0:
		curr_health = 0
	health_changed.emit(curr_health, MAX_HEALTH)

func regen_debounce():
	can_regen_health = true

# Movement

func _physics_process(delta: float) -> void:
	velocity = moveDirection * MOVE_SPEED

	if velocity.length_squared() > 0:
		var y_rotation = (-$Model.global_transform.basis.z).signed_angle_to(velocity, Vector3.UP)
		if absf(y_rotation) > TURN_SPEED_RADIANS:
			y_rotation = TURN_SPEED_RADIANS * signf(y_rotation)
		$Model.rotation.y += y_rotation
	elif faceDirection.length_squared() > 0:
		var y_rotation = (-$Model.global_transform.basis.z).signed_angle_to(faceDirection, Vector3.UP)
		if absf(y_rotation) > TURN_SPEED_RADIANS:
			y_rotation = TURN_SPEED_RADIANS * signf(y_rotation)
		$Model.rotation.y += y_rotation
		faceDirection = Vector3.ZERO

	move_and_slide()
