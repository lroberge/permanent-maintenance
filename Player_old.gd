extends CharacterBody3D

const TARGET_NAME = "Myself"

const deadzone = 0.3

@export var MOVE_SPEED = 5.0
@export var TURN_SPEED = 10.0
@onready var TURN_SPEED_RADIANS = deg_to_rad(TURN_SPEED)

@export_group("Player Camera")
## If true, only capture the mouse (and accept camera input) while RMB is held. Otherwise, always capture the mouse
@export var GRABBY = false
## Only with Grabby controls: If true, return the cursor to the position it was at before grabbing. Otherwise, reset the mouse to the center of the screen
@export var GRABBY_KEEP_CURSOR_POS = true
@export var INVERT_CAMERA_VERTICAL = false
@export var INVERT_CAMERA_HORIZONTAL = false
@export_range(0.01, 1.0, 0.01, "hide_slider", "or_greater") var SENSITIVITY = 0.1
@export_range(0.0, 1.0, 0.01, "hide_slider", "or_greater") var VERTICAL_SENSITIVITY = 0.0
@export_range(0.0, 1.0, 0.01, "hide_slider", "or_greater") var HORIZONTAL_SENSITIVITY = 0.0
## Lowest angle in degrees allowed for camera pitch.
@export var LOWER_LIMIT = -70.0
## Highest angle in degrees allowed for camera pitch.
@export var UPPER_LIMIT = 30.0
@export var MIN_ZOOM = 2
@export var MAX_ZOOM = 8
@export var ZOOM_SPEED = 10
@export var ZOOM_INCREMENT = 0.5

var previous_cursor_pos = Vector2.ZERO
var current_zoom = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if VERTICAL_SENSITIVITY <= 0:
		VERTICAL_SENSITIVITY = SENSITIVITY
	if HORIZONTAL_SENSITIVITY <= 0:
		HORIZONTAL_SENSITIVITY = SENSITIVITY
	$CameraArm.MIN_ZOOM = MIN_ZOOM
	$CameraArm.MAX_ZOOM = MAX_ZOOM
	$CameraArm.ZOOM_SPEED = ZOOM_SPEED
	$CameraArm.ZOOM_INCREMENT = ZOOM_INCREMENT
	# If not grabby controls, always capture the mouse
	if not GRABBY:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If cursor is merely confined, capture it properly (allowing full range of camera movement).
	if Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_close"):
		get_tree().quit()

	# Grabby controls - cursor is captured only while RMB held + controls camera only during that period
	if GRABBY:
		if event.is_action_pressed("camera_grab") and Input.is_action_just_pressed("camera_grab"):
			previous_cursor_pos = event.global_position
			# Confine and hide the cursor without forcibly moving it.
			# Prevents the cursor from visibly jumping to the center.
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		if event.is_action_released("camera_grab"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if GRABBY_KEEP_CURSOR_POS:
				get_tree().root.warp_mouse(previous_cursor_pos)

	if event is InputEventMouseMotion and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		$CameraArm.rotation_degrees.y -= (event.relative.x * HORIZONTAL_SENSITIVITY) * (-1 if INVERT_CAMERA_HORIZONTAL else 1)
		$CameraArm.rotation_degrees.x = clamp($CameraArm.rotation_degrees.x - ((event.relative.y * VERTICAL_SENSITIVITY) * (-1 if INVERT_CAMERA_VERTICAL else 1)), LOWER_LIMIT, UPPER_LIMIT)

func v2_xz_v3(v2: Vector2) -> Vector3:
	return Vector3(v2.x, 0, v2.y)
	pass

func _mouse_enter() -> void:
	CursorInputManager.mouse_entered_entity(self)
func _mouse_exit() -> void:
	CursorInputManager.mouse_left_entity(self)
func targeted() -> void:
	$PlayerModel/TargetingDecal.target()
func untargeted() -> void:
	$PlayerModel/TargetingDecal.untarget()

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	var inputDirection = Vector3(v2_xz_v3(Input.get_vector("player_left", "player_right", "player_fwd", "player_back")))
	var inputDirection_mag = clamp(inputDirection.length(), 0, 1)


	if inputDirection_mag < deadzone:
		inputDirection = Vector3.ZERO
	else:
		inputDirection = inputDirection.normalized() * ((inputDirection_mag - deadzone) / (1 - deadzone))
		velocity = inputDirection.rotated(Vector3.UP, $CameraArm.global_rotation.y) * MOVE_SPEED

	if velocity.length_squared() > 0:
		var y_rotation = (-$PlayerModel.global_transform.basis.z).signed_angle_to(velocity, Vector3.UP)
		if absf(y_rotation) > TURN_SPEED_RADIANS:
			y_rotation = TURN_SPEED_RADIANS * signf(y_rotation)
		$PlayerModel.rotation.y += y_rotation

	move_and_slide()
	pass
