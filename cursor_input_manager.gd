extends Node

var targeted_entity = null
var potential_target = null
var active_target = null

var potentially_targeting = false
var current_mouse_movement = 0
var max_mouse_movement = 5

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("cursor_target"):
		current_mouse_movement = 0
		potentially_targeting = true
		if targeted_entity != null:
			potential_target = targeted_entity
		else:
			potential_target = null

	if event is InputEventMouseMotion and potentially_targeting:
		current_mouse_movement += event.relative.length()
		print(event.relative)
		if current_mouse_movement > max_mouse_movement:
			potentially_targeting = false

	if Input.is_action_just_released("cursor_target") and potentially_targeting:
		active_target = potential_target
