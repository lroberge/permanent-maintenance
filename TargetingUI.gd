extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = CursorInputManager.active_target
	if target != null:
		text = "TARGET: " + target.TARGET_NAME
	else:
		text = "TARGET: (none)"
	pass
