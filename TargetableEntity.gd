extends AnimatableBody3D

const TARGET_NAME = "Clock Boss"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _mouse_enter() -> void:
	CursorInputManager.targeted_entity = self
func _mouse_exit() -> void:
	if CursorInputManager.targeted_entity == self:
		CursorInputManager.targeted_entity = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
#	if event.is_action_pressed("cursor_target"):
#		print("GOT ONE")
#		%TargetLabel.text = "TARGET: Clock Boss"
#	pass # Replace with function body.
