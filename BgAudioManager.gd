extends Node

# signal something_happened

@onready var audio = AudioStreamPlayer.new()
@onready var audiostack: Array[AudioStreamPlayer] = [AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new()]
var currplayer: AudioStreamPlayer:
	get:
		return audiostack.front()
	set(value):
		pass
var idleplayer: AudioStreamPlayer:
	get:
		return audiostack.back()
	set(value):
		pass
@onready var transitionaudio = AudioStreamPlayer.new()
var playing = false
var pauseloc = 0
var currtweens: Array[Tween] = []

var queued_audio: AudioStream = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	for i in audiostack.size():
#		audiostack[i].bus = "Bg" + str(i + 1)
	for audio in audiostack:
		audio.bus = &"Music"
		add_child(audio)
	add_child(audio)
	add_child(transitionaudio)
	# emit_signal("something_happened")
	# transitionaudio.volume_db = -6.0
	if queued_audio != null:
		load_and_play(queued_audio)

func queue_audio(newstream: AudioStream):
	queued_audio = newstream

func load_audio(newstream: AudioStream):
	var freshplayer = audiostack.pop_back()
	# emit_signal("something_happened")
	freshplayer.stream = newstream
	audiostack.push_front(freshplayer)
	# emit_signal("something_happened")
	return freshplayer

func load_audio_path(path: String):
	return load_audio(load(path))

func load_and_play(audio: AudioStream, seekpercent: float = 0.0, stopall: bool = true):
	if stopall:
		stop_everything()
	var player = load_audio(audio)
	var seekpoint = currplayer.stream.get_length() * seekpercent
	currplayer.play(seekpoint)
	return player
	# emit_signal("something_happened")

func load_and_play_path(path: String, seekpercent: float = 0.0, stopall: bool = true):
	return load_and_play(load(path), seekpercent, stopall)

func load_audio_transition(transitionaudio: AudioStream, transitiontime: float, audio: AudioStream):
	var drop_faded_audio = func(thisplayer: AudioStreamPlayer):
		thisplayer.stream = null
		# emit_something(1)

	var start_new_audio = func():
		load_and_play(audio, 0.0, false)

	var clear_stream = func(player: AudioStreamPlayer, thisfunc: Callable):
		player.finished.disconnect(thisfunc)
		player.stream = null
		# emit_something(1)

	fadeout(transitiontime, [idleplayer], drop_faded_audio, start_new_audio)
	var transitionplayer = load_and_play(transitionaudio, 0.0, false)
	currplayer.finished.connect(clear_stream.bind(currplayer, clear_stream))

func load_audio_transition_path(transitionpath: String, transitiontime: float, path: String):
	return load_audio_transition(load(transitionpath), transitiontime, load(path))

func load_audio_smooth(audio: AudioStream, transitiontime: float = 0.5):
	var drop_faded_audio = func(thisplayer: AudioStreamPlayer):
		thisplayer.stream = null
		# emit_something(1)

	fadeout(transitiontime, [idleplayer], drop_faded_audio)
	load_and_play(audio, 0.0, false)

func load_audio_smooth_path(path: String, transitiontime: float = 0.5):
	return load_audio_smooth(load(path), transitiontime)

# reference for all below:
# if audio is fully stopped, then both playing and stream_paused are false
# if audio is playing, then playing is true and stream_paused is false
# if audio is paused, then playing is false and stream_paused is true

func play():
	if not currplayer.playing and not currplayer.stream_paused:
		currplayer.play()
	currplayer.stream_paused = false
	# emit_signal("something_happened")

func pause():
	currplayer.stream_paused = true
	# emit_signal("something_happened")

func playpause():
	if not currplayer.playing and not currplayer.stream_paused:
		currplayer.play()
	else:
		currplayer.stream_paused = !currplayer.stream_paused
	# emit_signal("something_happened")

func stop():
	currplayer.stop()
	# emit_signal("something_happened")

func stop_everything(after: int = 0):
	for tween in currtweens:
		tween.custom_step(INF)
	for player in audiostack.slice(after):
		player.stream = null
		# emit_signal("something_happened")

# func emit_something(nullifier):
	# pass
	# emit_signal("something_happened")

func fadeout(time: float, exclude = [], callbackEach: Callable = Callable(), callbackAll: Callable = Callable()):
	var tofade = audiostack.duplicate()
	for exclusion in exclude:
		tofade.erase(exclusion)
	for player in tofade:
		_fadeout_single(player, time, callbackEach)
	if !callbackAll.is_null():
		var tween = get_tree().create_tween()
		tween.tween_interval(time)
		tween.tween_callback(callbackAll)


func _fadeout_single(player: AudioStreamPlayer, time: float, callback: Callable = Callable()):
	var tween = get_tree().create_tween()
	currtweens.push_back(tween)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	# tween the player volume to -60db (roughly silent)
	# tween.tween_method(emit_something, 0, 1, time)
	tween.tween_property(player, "volume_db", -60.0, time)
	tween.set_parallel(false)
	tween.tween_callback(player.stop)
	# emit_signal("something_happened")
	# after fading the audio out, reset the player volume
	tween.tween_property(player, "volume_db", 0, 0)
	# emit_signal("something_happened")
	if !callback.is_null():
		tween.tween_callback(callback.bind(player))
	tween.tween_callback(func(): currtweens.erase(tween))

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
