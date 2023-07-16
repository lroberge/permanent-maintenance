@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ProgressSlider.value = %HealthBar.value
	%PercentLabel.value = %HealthBar.value
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_progress_slider_value_changed(value: float) -> void:
	%HealthBar.value = value
	%PercentLabel.text = str(value) + "%"
	pass # Replace with function body.
