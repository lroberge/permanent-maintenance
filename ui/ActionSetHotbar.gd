extends Control

@export var bar_name: String = "Heal"
@export var actions: Array[PlayerActionDefinition] = []
@export var initially_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BarName.text = bar_name
	for idx in min(4, actions.size()):
		get_node("%ActionButton" + str(idx)).set_action(actions[idx])
	set_active(initially_active)

func set_active(is_active: bool):
	if is_active:
		ActionsCoord.register_actionset(actions)
	for idx in range(4):
		var btn = get_node("%ActionButton" + str(idx))
		btn.disabled = !is_active
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if is_active else Control.MOUSE_FILTER_IGNORE
