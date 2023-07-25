extends Button

const ON_COOLDOWN_COLOR = Color("#545454")
const OFF_COOLDOWN_COLOR = Color("#fff")
const GCD_OVERLAY_MAX_HEIGHT = 130

@export var action: PlayerActionDefinition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_action(action: PlayerActionDefinition):
	self.action = action
	if self.action != null:
		icon = self.action.icon


func _process(delta: float) -> void:
	if action != null:
		var cd = ActionsCoord.get_action_cooldown(action.id)
		if cd > 0:
			disabled = true
			self_modulate = ON_COOLDOWN_COLOR
			$CooldownLeft.text = str(roundi(cd))
			$CooldownLeft.visible = true
		else:
			disabled = false
			$CooldownLeft.visible = false
			self_modulate = OFF_COOLDOWN_COLOR

	var gcd = ActionsCoord.get_global_cooldown_percent()
	$GCDOverlay.size.y = GCD_OVERLAY_MAX_HEIGHT * gcd
	if gcd > 0:
		disabled = true
