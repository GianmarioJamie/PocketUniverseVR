extends Node
## A short, optional discovery journey. No timer, score or changes to free play.
signal changed(state: Dictionary)
enum Mode { FREE, JOURNEY, COMPLETE }
var mode := Mode.FREE
var stop := 0
var stars := 0
var waiting := false
var earth_seen := false
var sun_started := false
var sun_moved := false
var sun_start := Vector3.ZERO
var sound_count := 0
var player: AudioStreamPlayer
var chimes: Array[AudioStreamWAV] = []

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.volume_db = -19.0
	add_child(player)
	for frequency in [523.25,659.25,783.99]:
		chimes.append(_make_chime(frequency))

func state() -> Dictionary:
	var result := {"heading":"THREE WONDERS", "instruction":"Follow a short journey, or explore at your own pace.", "stars":stars, "primary_label":"Start again" if stars>0 else "Start journey", "primary_enabled":true, "free_enabled":mode!=Mode.FREE}
	if mode==Mode.COMPLETE:
		result.heading = "JOURNEY COMPLETE"
		result.instruction = "Three wonders discovered. Your little universe is yours to explore."
		result.primary_label = "Start again"
	elif mode==Mode.JOURNEY:
		result.heading = ["1 / 3  OUR HOME","2 / 3  A WORLD OF RINGS","3 / 3  THE COSMIC CONDUCTOR"][stop]
		result.primary_enabled = waiting
		result.primary_label = "Next discovery" if waiting else "Exploring..."
		if waiting:
			result.instruction = ["One Moon, two spacecraft: Earth has a busy neighbourhood.","Saturn's rings are made of countless pieces of ice and rock.",""][stop]
		elif stop==0:
			result.instruction = "Pinch the Moon, or choose Discover Moon below." if earth_seen else "Grab / Pinch Earth to reveal its Moon and nearby spacecraft."
			if earth_seen:
				result.primary_label = "Discover Moon"
				result.primary_enabled = true
		elif stop==1:
			result.instruction = "Grab / Pinch Saturn to admire its rings."
		else:
			result.instruction = "Pinch Pause / Play to stop the orbits and take it all in." if sun_moved else "Grab / Pinch the Sun and move your universe. Then pause the orbits."
	return result

func primary() -> void:
	if mode!=Mode.JOURNEY:
		mode = Mode.JOURNEY
		stop = 0
		stars = 0
	elif waiting:
		stop+=1
	else:
		return
	waiting = false
	earth_seen = false
	sun_started = false
	sun_moved = false
	_emit()

func explore_freely() -> void:
	if mode==Mode.FREE:
		return
	mode = Mode.FREE
	waiting = false
	_emit()

func target_action() -> int:
	if mode!=Mode.JOURNEY or waiting:
		return -1
	return [2,5,120][stop]

func can_discover_moon() -> bool:
	return mode==Mode.JOURNEY and stop==0 and earth_seen and not waiting

func show_earth_neighbourhood() -> bool:
	return mode==Mode.JOURNEY and stop==0 and earth_seen

func observe(earth_held: bool, saturn_held: bool, sun_held: bool, sun_position: Vector3, orbits_paused: bool) -> void:
	if mode!=Mode.JOURNEY or waiting:
		return
	if stop==0:
		if earth_held and not earth_seen:
			earth_seen = true
			_emit()
	elif stop==1 and saturn_held:
		_complete_stop()
	elif stop==2:
		if sun_held:
			if not sun_started:
				sun_started = true
				sun_start = sun_position
			if not sun_moved and sun_position.distance_to(sun_start)>=0.03:
				sun_moved = true
				_emit()
		elif sun_started and not sun_moved:
			# A new grab starts a new movement, rather than counting zoom/reset.
			sun_started = false
		if sun_moved and orbits_paused:
			_complete_stop()

func select_companion(index: int, earth_held: bool) -> void:
	if mode==Mode.JOURNEY and stop==0 and not waiting and index==0 and (earth_seen or earth_held):
		earth_seen = true
		_complete_stop()

func reset_motion() -> void:
	# Recenter/reset placement must never count as physically moving the Sun.
	if mode==Mode.JOURNEY and stop==2 and not sun_moved:
		sun_started = false

func _complete_stop() -> void:
	stars = stop+1
	waiting = true
	if stop==2:
		mode = Mode.COMPLETE
	if is_instance_valid(player):
		player.stream = chimes[stars-1]
		player.play()
	sound_count+=1
	_emit()

func _emit() -> void:
	changed.emit(state())

func _make_chime(frequency: float) -> AudioStreamWAV:
	# Original, quiet two-note UI chime; generated locally, no external assets.
	const RATE := 22050
	const DURATION := 0.38
	var samples := int(RATE*DURATION)
	var pcm := PackedByteArray()
	pcm.resize(samples*2)
	for i in samples:
		var t := float(i)/RATE
		var envelope := minf(t/0.025,1.0)*pow(1.0-t/DURATION,2.0)
		var tone := sin(TAU*frequency*t)*0.55+sin(TAU*frequency*1.5*t)*0.20
		pcm.encode_s16(i*2,int(tone*envelope*20000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = pcm
	return stream
