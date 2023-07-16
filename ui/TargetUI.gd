extends Control

@export var TWEEN_SPEED = 1.0

var health_bar_tween = null
var health_bar_bg_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CursorInputManager.target_changed.connect(update_target)
	%HealthBar.value_changed.connect(update_health_percent)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_health_percent(value: float) -> void:
	%PercentLabel.text = str(ceili(value * 100.0)) + "%"

func update_target(new_target: CombatBody, old_target: CombatBody) -> void:
	if new_target != null:
		%NameLabel.text = new_target.TARGET_NAME
		%HealthBar.value = new_target.curr_health / new_target.MAX_HEALTH
		%HealthBarBG.value = new_target.curr_health / new_target.MAX_HEALTH
		%PercentLabel.text = str(ceili((new_target.curr_health / new_target.MAX_HEALTH) * 100.0)) + "%"
		new_target.health_changed.connect(update_health)
		visible = true
	else:
		visible = false

	if old_target != null and new_target != old_target:
		old_target.health_changed.disconnect(update_health)
	pass

func update_health(new_health: float, max_health: float):
	# Tween health bar value (quartic transition with ease out)
	if health_bar_tween:
		health_bar_tween.kill()
	health_bar_tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	health_bar_tween.tween_property(%HealthBar, "value", new_health / max_health, TWEEN_SPEED)

	# Tween health bar "draining" effect value (linear transition no easing)
	if health_bar_bg_tween:
		health_bar_bg_tween.kill()
	health_bar_bg_tween = create_tween()
	health_bar_bg_tween.tween_property(%HealthBarBG, "value", new_health / max_health, TWEEN_SPEED)

