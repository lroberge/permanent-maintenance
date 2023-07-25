class_name CompoundAttack extends Node3D

@export var attack_name = "changeme"
@onready var aoe_groupname = attack_name + "_aoes"
@export var attack_aoes: Array[AoE] = []
@export var attract_nodes: Array[InfluencePoint] = []
@export var avoid_nodes: Array[InfluencePoint] = []
@export var random_rotation_step = 0
@export var damage_per_aoe = 10.0
@export var cast_time = 3.0
@export var color = Color("#ff1a00")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.y = 0
	pass # Replace with function body.

func fire(from: CombatBody = null) -> void:
	if random_rotation_step > 0:
		var rot_increment = randi_range(0, int(ceil(360 / random_rotation_step) - 1))
		# print("rot increment: " + str(rot_increment))
		rotation_degrees.y = rot_increment * random_rotation_step
	for aoe in attack_aoes:
		aoe.add_to_group(aoe_groupname)
		aoe.set_up(AoEs.damage_callback(damage_per_aoe, from), cast_time, color)
	for aoe in attack_aoes:
		aoe.start_unmoving()

	# print("creating " + attack_name + " with rotation " + str(rotation_degrees.y))
	EncounterManager.add_influencepoints(attract_nodes, avoid_nodes)
	EncounterManager.attack_fired.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group(aoe_groupname).size() <= 0:
		EncounterManager.clear_influencepoints()
		EncounterManager.attack_finished.emit()
		queue_free()
	pass
