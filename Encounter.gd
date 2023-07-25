class_name Encounter extends Node3D

@export var active: bool = false
@export var main_enemy: CombatBody
@export var music: AudioStream
@export var post_enc_music: AudioStream
@export_range(0, 4, 0.01, "or_greater") var ALERTA_pitch: float = 1.0

func _ready() -> void:
	main_enemy.health_changed.connect(check_health)

func check_health(new_health, old_health):
	if new_health <= 0:
		EncounterManager.deactivate_encounter(self)
	pass


func _on_encounter_entered(body: Node3D) -> void:
	EncounterManager.activate_encounter(self)
	main_enemy.start_going()
	$EncounterStartTrigger.queue_free()
