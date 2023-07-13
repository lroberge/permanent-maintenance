extends CharacterBody3D

const deadzone = 0.3

@export var MOVE_SPEED = 5.0
@export var TURN_SPEED = 10.0
@onready var TURN_SPEED_RADIANS = deg_to_rad(TURN_SPEED)

@export_group("Player Camera")
## If true, only capture the mouse (and accept camera input) while RMB is held. Otherwise, always capture the mouse
@export var GRABBY = false
## Only with Grabby controls: If true, return the cursor to the position it was at before grabbing. Otherwise, reset the mouse to the center of the screen
@export var GRABBY_KEEP_CURSOR_POS = true
@export var SENSITIVITY = 0.1
## Lowest angle in degrees allowed for camera pitch.
@export var LOWER_LIMIT = -70.0
## Highest angle in degrees allowed for camera pitch.
@export var UPPER_LIMIT = 30.0

var previous_cursor_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If not grabby controls, always capture the mouse
	if not GRABBY:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_close"):
		get_tree().quit()

	# Grabby controls - cursor is captured only while RMB held + controls camera only during that period
	if GRABBY:
		if event.is_action_pressed("camera_grab"):
			previous_cursor_pos = event.position
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event.is_action_released("camera_grab"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if GRABBY_KEEP_CURSOR_POS:
				Input.warp_mouse(previous_cursor_pos)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$CameraArm.rotation_degrees.y -= event.relative.x * SENSITIVITY
		$CameraArm.rotation_degrees.x = clamp($CameraArm.rotation_degrees.x - event.relative.y * SENSITIVITY, LOWER_LIMIT, UPPER_LIMIT)

func v2_xz_v3(v2: Vector2) -> Vector3:
	return Vector3(v2.x, 0, v2.y)
	pass

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
