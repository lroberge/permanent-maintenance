extends Node

signal encounter_started
signal encounter_ended
signal attack_fired
signal attack_finished

const ALERTA_SOUND = preload("res://assets/ALERTA_COMBINED.mp3")
const IDLE_MUSIC = preload("res://assets/external/music/ascension.wav")

static var active_encounter: Encounter = null
static var all_encounters: Array[Encounter] = []
static var safepoints = []
static var dangerpoints = []

func _ready():
	AudioManager.queue_audio(IDLE_MUSIC)
	pass

func activate_encounter(enc: Encounter):
	active_encounter = enc
	enc.active = true
	AudioManager.load_audio_transition(ALERTA_SOUND, 2, enc.music)
	encounter_started.emit()

func add_influencepoints(safe: Array[InfluencePoint], danger: Array[InfluencePoint]):
	safepoints = safepoints + safe.duplicate()
	dangerpoints = dangerpoints + danger.duplicate()

func clear_influencepoints():
	safepoints = []
	dangerpoints = []

func deactivate_encounter(enc: Encounter):
	if active_encounter == enc:
		active_encounter = null
		enc.active = false
		if enc.post_enc_music != null:
			AudioManager.load_audio_smooth(enc.post_enc_music, 5)
		else:
			AudioManager.load_audio_smooth(IDLE_MUSIC, 5)
		encounter_ended.emit()

func create_pathing_point(pos: Vector3, attract = false):
	pass
