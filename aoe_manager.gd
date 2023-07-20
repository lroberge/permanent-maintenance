class_name AoEs extends Node

const BasicAoEs = {
	"circle": preload("res://attacks/CircularAoE.tscn"),
	"square": preload("res://attacks/SquareAoE.tscn"),
	"line": preload("res://attacks/LineAoE.tscn")
}

func create_aoe(aoe_scene: PackedScene, callback: Callable, position: Vector3, scale: float = 1.0):
	var new_aoe = aoe_scene.instantiate() as AoE
	new_aoe.set_up(callback)
	add_child(new_aoe)
	new_aoe.start(position, scale)

func create_line_aoe(rotation: float, callback: Callable, position: Vector3, scale: float = 1.0):
	var new_aoe = BasicAoEs.line.instantiate() as AoE
	new_aoe.set_up(callback)
	add_child(new_aoe)
	new_aoe.rotation_degrees.y = rotation
	new_aoe.start(position, scale)

func create_tracking_aoe(aoe_scene: PackedScene, callback: Callable, body: Node3D, scale: float = 1.0):
	var new_aoe = aoe_scene.instantiate() as AoE
	new_aoe.set_up(callback)
	add_child(new_aoe)
	new_aoe.start_tracking(body, scale)

static func damage_callback(damage: float, from: CombatBody):
	return func (aoe: AoE):
		Damage.deal_aoe(damage, aoe, from)

