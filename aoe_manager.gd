class_name AoEs extends Node

const BasicAoEs = {
	"circle": preload("res://attacks/CircularAoE.tscn"),
	"square": preload("res://attacks/SquareAoE.tscn"),
	"line": preload("res://attacks/LineAoE.tscn")
}

func create_aoe(settings: AoeSettings):
	var new_aoe = settings.aoe_scene.instantiate() as AoE
	new_aoe.set_up(settings.callback, settings.warning_time, settings.color)
	get_tree().root.add_child(new_aoe)
	new_aoe.rotation_degrees.y = settings.rotation
	if settings.tracking != null:
		new_aoe.start_tracking(settings.tracking, settings.scale)
	else:
		new_aoe.start(settings.position, settings.scale)

	return new_aoe

#static func create_aoeset(settings: Array[AoeSettings]):
#	var prepped_aoes = []
#	for setting in settings:
#		var new_aoe = setting.aoe_scene.instantiate() as AoE
#		new_aoe.set_up(setting.callback, setting.warning_time, setting.color)
#		EncounterManager.active_encounter.add_child(new_aoe)
#		new_aoe.rotation_degrees.y = setting.rotation + EncounterManager.active_encounter.rotation.y
#		if setting.tracking != null:
#			new_aoe.start_tracking(setting.tracking, setting.scale)
#		else:
#			new_aoe.start(EncounterManager.active_encounter.to_global(setting.position), setting.scale)

static func damage_callback(damage: float, from: CombatBody):
	return func (aoe: AoE):
		Damage.deal_aoe(damage, aoe, from)

static func healing_callback(healing: float, from: CombatBody, percent: bool = false):
	return func (aoe: AoE):
		Damage.heal_aoe(healing, aoe, from, percent)
