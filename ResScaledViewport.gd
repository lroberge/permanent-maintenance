extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = get_tree().root.size
	print(size)
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_viewport_size_changed():
	size = get_tree().root.size
	print(size)
	pass
