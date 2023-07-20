class_name AoE extends Area3D

var damage_callback: Callable
var warning_time: float
var tracking_body: Node3D = null

@export var vfx_scene: PackedScene

func set_up(damage_callback: Callable, warning_time = 3.0, color: Color = Color("#ff1a00")):
	var sceneinstance = vfx_scene.instantiate()
	add_child(sceneinstance)
	self.damage_callback = damage_callback
	self.warning_time = warning_time
	$VFX/AnimationPlayer.animation_finished.connect(anim_finished)
	$VFX.AoEColor = color

func start(pos: Vector3 = Vector3.ZERO, scale: float = 1.0):
	position = pos
	self.scale = Vector3(scale, scale, scale)
	$VFX/AnimationPlayer.play("spawn")

func start_tracking(body: Node3D, scale: float = 1.0):
	tracking_body = body
	self.start(body.global_position, scale)

func _process(delta: float) -> void:
	if tracking_body != null:
		position = tracking_body.global_position

func anim_finished(anim: StringName):
	if anim == "spawn":
		var timescale = 1 / warning_time
		$VFX/AnimationPlayer.play("countdown_to_aoe", -1, timescale)
	elif anim == "countdown_to_aoe":
		damage_callback.call(self)
		$VFX/AnimationPlayer.play("despawn")
		pass
	elif anim == "despawn":
		queue_free()
