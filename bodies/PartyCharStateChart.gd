extends StateChart

@onready var parent_char = get_parent()

var reaction_time: float:
	get:
		return parent_char.reaction_time
var reaction_time_variability: float:
	get:
		return parent_char.reaction_time_variability

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EncounterManager.encounter_started.connect(func(): self.send_event("encounter_started"))
	EncounterManager.encounter_ended.connect(func(): self.send_event("encounter_ended"))
	EncounterManager.attack_fired.connect(func(): call_deferred("realize_the_danger"))
	EncounterManager.attack_finished.connect(func(): call_deferred("realize_the_lack_of_danger"))
	super()

func realize_the_danger():
	var curr_reaction_time = reaction_time + randf_range(-reaction_time_variability, reaction_time_variability)
	await get_tree().create_timer(curr_reaction_time).timeout
	self.send_event("attack_noticed")

func realize_the_lack_of_danger():
	await get_tree().create_timer(randf_range(0.2, 0.75)).timeout
	self.send_event("attack_end_noticed")
