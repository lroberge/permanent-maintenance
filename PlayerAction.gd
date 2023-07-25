class_name PlayerActionDefinition extends Resource

@export var icon: Texture2D
@export var name: String
@export var id: StringName
@export var cast_time: float
@export var cooldown: float
@export_multiline var description: String

func _init():
	icon = null
	name = ""
	id = ""
	cast_time = 0.0
	cooldown = 0.0
	description = ""
