extends SceneTree
## Automated headless tests for Phase 7 (AudioManager synthesis, settings gating, BoardRenderer flash).

var _failures: int = 0
var _main_node: Main
var _ran: bool = false


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main/main.tscn")
	_assert_true(packed != null, "main.tscn must load cleanly")
	if packed != null:
		_main_node = packed.instantiate() as Main
		root.add_child(_main_node)


func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true

	if _main_node != null:
		_test_audio_manager(_main_node.audio_manager)
		_test_board_flash(_main_node.game_scene.board_renderer)
		_main_node.free()
		_main_node = null

	if _failures == 0:
		print("PASS: All Phase 7 audio & polish tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 7 test(s) failed." % _failures)
		quit(1)
	return true


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		printerr("  [FAIL] " + message)
		_failures += 1


func _test_audio_manager(audio: AudioManager) -> void:
	_assert_true(audio != null, "Main must create AudioManager")
	if audio == null:
		return

	_assert_true(audio._clip_eat != null and audio._clip_eat.data.size() > 0, "Eat SFX WAV must have audio samples")
	_assert_true(audio._clip_click != null and audio._clip_click.data.size() > 0, "Click SFX WAV must have audio samples")
	_assert_true(audio._clip_game_over != null and audio._clip_game_over.data.size() > 0, "Game Over SFX WAV must have audio samples")
	_assert_true(audio._clip_win != null and audio._clip_win.data.size() > 0, "Win SFX WAV must have audio samples")
	_assert_true(audio._clip_music != null and audio._clip_music.data.size() > 0, "Music WAV must have audio samples")
	_assert_true(audio._clip_music.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Music clip must be looping")

	# Verify settings gating works cleanly without errors
	audio.apply_settings(false, false)
	_assert_true(not audio.sfx_enabled and not audio.music_enabled, "Audio settings must update to disabled")
	audio.play_eat()
	audio.play_click()
	audio.play_game_over()
	audio.play_win()

	audio.apply_settings(true, true)
	_assert_true(audio.sfx_enabled and audio.music_enabled, "Audio settings must update to enabled")
	audio.play_click()
	audio.apply_settings(true, false)


func _test_board_flash(board: BoardRenderer) -> void:
	_assert_true(board != null, "BoardRenderer must exist")
	if board == null:
		return
	board.trigger_eat_flash()
	_assert_true(board._flash_timer > 0.0 and not board._flash_is_collision, "Eat flash should set non-collision timer")
	board.trigger_collision_flash()
	_assert_true(board._flash_timer > 0.0 and board._flash_is_collision, "Collision flash should set collision timer")
