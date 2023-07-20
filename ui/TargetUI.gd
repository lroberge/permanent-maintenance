extends Control

@export var TWEEN_SPEED = 1.0
@export var TEAM_COLORS: Array[Color] = [Color.ORANGE_RED, Color.GREEN_YELLOW, Color.DEEP_PINK]
@export_color_no_alpha var DAMAGE_COLOR: Color = Color.LIGHT_PINK
@export_color_no_alpha var HEAL_COLOR: Color = Color.MEDIUM_SPRING_GREEN

var healing = false
var should_be_visible = false
var health_bar_tween: Tween = null
var health_bar_bg_tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CursorInputManager.target_changed.connect(update_target)
	%HealthBar.value_changed.connect(update_health_percent)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = should_be_visible
	pass

func update_health_percent(value: float) -> void:
	%PercentLabel.text = str(ceili(value * 100.0)) + "%"

func update_target(new_target: CombatBody, old_target: CombatBody) -> void:
	# covering all my bases i'm so sorry
	var new_target_isnt_old_target = (old_target != null) and (new_target != old_target)

	if new_target_isnt_old_target and old_target.health_changed.is_connected(update_health_bar):
		old_target.health_changed.disconnect(update_health_bar)

	if new_target != null and ((old_target == null) or new_target_isnt_old_target):
		if new_target_isnt_old_target:
			if health_bar_tween: health_bar_tween.kill()
			if health_bar_bg_tween: health_bar_bg_tween.kill()
			if old_target.health_changed.is_connected(update_health_bar):
				old_target.health_changed.disconnect(update_health_bar)

		%NameLabel.text = new_target.TARGET_NAME
		%HealthBar.value = new_target.curr_health / new_target.MAX_HEALTH
		%HealthBarDamageBG.value = new_target.curr_health / new_target.MAX_HEALTH
		%HealthBar.tint_progress = TEAM_COLORS[new_target.TEAM]
		%NameLabel.label_settings.outline_color = TEAM_COLORS[new_target.TEAM]
		%PercentLabel.text = str(ceili((new_target.curr_health / new_target.MAX_HEALTH) * 100.0)) + "%"
		new_target.health_changed.connect(update_health_bar)
		should_be_visible = true
	elif new_target == null:
		should_be_visible = false

func update_health_bar(new_health: float, max_health: float):
	# Tween health bar value (quartic transition with ease out)
	if health_bar_tween:
		health_bar_tween.kill()
	if new_health > %HealthBar.value * max_health:
		healing = true
	else:
		healing = false
	health_bar_tween = create_tween().set_trans(Tween.TRANS_QUART if not healing else Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	health_bar_tween.tween_property(%HealthBar, "value", new_health / max_health, TWEEN_SPEED)

	# Tween health bar "draining" effect value (linear transition no easing)
	if health_bar_bg_tween:
		health_bar_bg_tween.kill()
	%HealthBarDamageBG.tint_progress = DAMAGE_COLOR if not healing else HEAL_COLOR
	health_bar_bg_tween = create_tween() \
		.set_trans(Tween.TRANS_QUART if healing else Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT if healing else Tween.EASE_IN_OUT)
	health_bar_bg_tween.tween_property(%HealthBarDamageBG, "value", new_health / max_health, TWEEN_SPEED)

