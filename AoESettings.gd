class_name AoeSettings extends RefCounted

var aoe_scene: PackedScene
var callback: Callable
var tracking: Node3D = null
var position: Vector3 = Vector3.ZERO
var scale: float = 1.0
var rotation: float = 0.0
var color: Color = Color("#ff1a00")
var warning_time: float = 3.0

func _init(aoe_def, i_callback) -> void:
	if aoe_def is PackedScene:
		self.aoe_scene = aoe_def
	else:
		self.aoe_scene = AoeManager.BasicAoEs[aoe_def]
	self.callback = i_callback

func with_tracking(new_tracked) -> AoeSettings:
	self.tracking = new_tracked
	return self
func with_position(new_position) -> AoeSettings:
	self.position = new_position
	return self
func with_scale(new_scale) -> AoeSettings:
	self.scale = new_scale
	return self
func with_rotation(new_rotation) -> AoeSettings:
	self.rotation = new_rotation
	return self
func with_color(new_color) -> AoeSettings:
	self.color = new_color
	return self
func with_warntime(new_warntime) -> AoeSettings:
	self.warning_time = new_warntime
	return self
