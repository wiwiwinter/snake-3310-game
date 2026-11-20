class_name AudioManager
extends Node
## Synthesizes and plays original Nokia-inspired piezo SFX and optional chiptune background music.

const SAMPLE_RATE: int = 22050

var sfx_enabled: bool = true
var music_enabled: bool = true

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer

var _clip_eat: AudioStreamWAV
var _clip_click: AudioStreamWAV
var _clip_game_over: AudioStreamWAV
var _clip_win: AudioStreamWAV
var _clip_music: AudioStreamWAV


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.volume_db = -8.0
	add_child(_sfx_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = -18.0
	add_child(_music_player)

	_clip_eat = _build_sequence([Vector2(660.0, 0.045), Vector2(990.0, 0.055)], 0.35)
	_clip_click = _build_sequence([Vector2(880.0, 0.03)], 0.25)
	_clip_game_over = _build_sequence([
		Vector2(440.0, 0.11),
		Vector2(330.0, 0.11),
		Vector2(220.0, 0.18),
	], 0.35)
	_clip_win = _build_sequence([
		Vector2(523.25, 0.08),
		Vector2(659.25, 0.08),
		Vector2(783.99, 0.08),
		Vector2(1046.50, 0.16),
	], 0.35)


func _ensure_music_clip() -> AudioStreamWAV:
	if _clip_music == null:
		# Original 8-note retro chiptune loop (C-major pentatonic pulse), built lazily when enabled.
		_clip_music = _build_sequence([
			Vector2(261.63, 0.18), Vector2(0.0, 0.04),
			Vector2(329.63, 0.18), Vector2(0.0, 0.04),
			Vector2(392.00, 0.18), Vector2(0.0, 0.04),
			Vector2(329.63, 0.18), Vector2(0.0, 0.04),
			Vector2(293.66, 0.18), Vector2(0.0, 0.04),
			Vector2(349.23, 0.18), Vector2(0.0, 0.04),
			Vector2(392.00, 0.18), Vector2(0.0, 0.04),
			Vector2(293.66, 0.22), Vector2(0.0, 0.08),
		], 0.18, true)
	return _clip_music


func set_paused(paused: bool) -> void:
	if _music_player != null:
		_music_player.stream_paused = paused


func _exit_tree() -> void:
	if _sfx_player != null:
		_sfx_player.stop()
		_sfx_player.stream = null
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null


func apply_settings(p_sfx_enabled: bool, p_music_enabled: bool) -> void:
	sfx_enabled = p_sfx_enabled
	music_enabled = p_music_enabled
	if _music_player == null:
		return
	if music_enabled:
		if not _music_player.playing:
			_music_player.stream = _ensure_music_clip()
			_music_player.stream_paused = false
			_music_player.play()
	else:
		_music_player.stop()


func play_eat() -> void:
	_play_sfx(_clip_eat)


func play_click() -> void:
	_play_sfx(_clip_click)


func play_game_over() -> void:
	_play_sfx(_clip_game_over)


func play_win() -> void:
	_play_sfx(_clip_win)


func _play_sfx(clip: AudioStreamWAV) -> void:
	if not sfx_enabled or _sfx_player == null or clip == null:
		return
	_sfx_player.stream = clip
	_sfx_player.play()


func _build_sequence(notes: Array[Vector2], amplitude: float, looping: bool = false) -> AudioStreamWAV:
	var total_samples: int = 0
	for n in notes:
		total_samples += int(round(n.y * float(SAMPLE_RATE)))

	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2) # 16-bit mono PCM

	var cursor: int = 0
	for n in notes:
		var freq: float = n.x
		var count: int = int(round(n.y * float(SAMPLE_RATE)))
		for i in range(count):
			var sample_val: float = 0.0
			if freq > 0.0:
				var phase: float = fmod(float(i) * freq / float(SAMPLE_RATE), 1.0)
				sample_val = amplitude if phase < 0.5 else -amplitude
				# Tiny 2ms fade-out at note tail prevents audio click artifacts.
				var tail: int = count - i
				if tail < 44:
					sample_val *= float(tail) / 44.0
			var pcm: int = clampi(int(sample_val * 32767.0), -32768, 32767)
			bytes[cursor * 2] = pcm & 0xFF
			bytes[cursor * 2 + 1] = (pcm >> 8) & 0xFF
			cursor += 1

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	if looping:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = total_samples
	return wav
