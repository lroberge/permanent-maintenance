extends SpringArm3D

@export var MIN_ZOOM = 2
@export var MAX_ZOOM = 8
@export var ZOOM_SPEED = 5
@export var ZOOM_INCREMENT = 0.5

var current_zoom = 6
var previous_hit_length = current_zoom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_hit_length() < previous_hit_length:
		spring_length = get_hit_length()
		previous_hit_length = get_hit_length()
	else:
		if current_zoom > MAX_ZOOM:
			current_zoom = MAX_ZOOM
		if current_zoom < MIN_ZOOM:
			current_zoom = MIN_ZOOM
		spring_length += (current_zoom - spring_length) * (delta * ZOOM_SPEED)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoomin"):
		current_zoom -= ZOOM_INCREMENT
	if event.is_action_pressed("camera_zoomout"):
		current_zoom += ZOOM_INCREMENT
