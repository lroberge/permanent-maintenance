extends Node

## Current entity that will be targeted if clicked
var hovered_entity: CombatBody = null
var potential_target: CombatBody = null
var active_target: CombatBody = null

## If this is true, and cursor_target is released, active_target will be set to the value of potential_target
var potentially_targeting = false
var current_mouse_movement = 0
var max_mouse_movement = 5

func mouse_entered_entity(ent: CombatBody):
	hovered_entity = ent
func mouse_left_entity(ent: CombatBody):
	if hovered_entity == ent:
		hovered_entity = null

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("cursor_target"):
		current_mouse_movement = 0
		potentially_targeting = true
		if hovered_entity != null:
			potential_target = hovered_entity
		else:
			potential_target = null

	if event is InputEventMouseMotion and potentially_targeting:
		current_mouse_movement += event.relative.length()
		print(event.relative)
		if current_mouse_movement > max_mouse_movement:
			potentially_targeting = false

	if Input.is_action_just_released("cursor_target") and potentially_targeting:
		if active_target != null:
			active_target.untargeted()
		active_target = potential_target
		if active_target != null:
			active_target.targeted()
