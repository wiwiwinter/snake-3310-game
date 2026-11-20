extends SceneTree
## Automated headless tests for Phase 6 (SwipeDetector, settings persistence, 7 screens & navigation).

const TEST_SAVE_PATH: String = "res://.godot/test_phase6_save.cfg"

var _failures: int = 0
var _main_node: Main
var _ran_scene_tests: bool = false


func _initialize() -> void:
	_cleanup_test_file()
	_test_swipe_detector()
	_test_settings_persistence()

	var packed: PackedScene = load("res://scenes/main/main.tscn")
	_assert_true(packed != null, "main.tscn must load cleanly")
	if packed != null:
		_main_node = packed.instantiate() as Main
		root.add_child(_main_node)


func _process(_delta: float) -> bool:
	if _ran_scene_tests:
		return true
	_ran_scene_tests = true

	if _main_node != null:
		_test_screen_navigation_and_tap_targets(_main_node)
		_main_node.free()
		_main_node = null

	_cleanup_test_file()
	if _failures == 0:
		print("PASS: All Phase 6 UI/UX, swipe & navigation tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 6 test(s) failed." % _failures)
		quit(1)
	return true


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		printerr("  [FAIL] " + message)
		_failures += 1


func _cleanup_test_file() -> void:
	var abs_path: String = ProjectSettings.globalize_path(TEST_SAVE_PATH)
	if FileAccess.file_exists(abs_path):
		DirAccess.remove_absolute(abs_path)


func _test_swipe_detector() -> void:
	var sd := SwipeDetector.new(28.0)
	sd.begin_drag(Vector2(100, 100))
	_assert_true(sd.update_drag(Vector2(115, 105)) == Vector2i.ZERO, "Drag under threshold must not trigger")
	_assert_true(sd.update_drag(Vector2(140, 105)) == Vector2i.RIGHT, "Horizontal +X drag must return RIGHT")
	_assert_true(sd.update_drag(Vector2(200, 105)) == Vector2i.ZERO, "Same drag must only trigger once")
	sd.end_drag()

	sd.begin_drag(Vector2(100, 100))
	_assert_true(sd.update_drag(Vector2(95, 60)) == Vector2i.UP, "Vertical -Y drag must return UP")
	sd.end_drag()

	sd.begin_drag(Vector2(100, 100))
	_assert_true(sd.update_drag(Vector2(60, 102)) == Vector2i.LEFT, "Horizontal -X drag must return LEFT")
	sd.end_drag()

	sd.begin_drag(Vector2(100, 100))
	_assert_true(sd.update_drag(Vector2(104, 140)) == Vector2i.DOWN, "Vertical +Y drag must return DOWN")
	sd.end_drag()


func _test_settings_persistence() -> void:
	_cleanup_test_file()
	var mgr := ScoreManager.new(TEST_SAVE_PATH)
	mgr.set_wrap_walls(true)
	mgr.set_sfx_enabled(false)
	mgr.set_music_enabled(false)
	mgr.set_classic_dpad(true)

	var reloaded := ScoreManager.new(TEST_SAVE_PATH)
	_assert_true(reloaded.wrap_walls == true, "wrap_walls=true must persist")
	_assert_true(reloaded.sfx_enabled == false, "sfx_enabled=false must persist")
	_assert_true(reloaded.music_enabled == false, "music_enabled=false must persist")
	_assert_true(reloaded.classic_dpad == true, "classic_dpad=true must persist")


func _test_screen_navigation_and_tap_targets(main_node: Main) -> void:
	main_node.score_manager = ScoreManager.new(TEST_SAVE_PATH)
	main_node.game_scene.configure(main_node.score_manager)

	_assert_true(main_node.current_screen == Main.Screen.SPLASH, "Initial screen must be SPLASH")

	main_node.show_main_menu()
	_assert_true(main_node.current_screen == Main.Screen.MAIN_MENU, "Should switch to MAIN_MENU")
	_assert_true(main_node.main_menu.visible and not main_node.splash_screen.visible, "Only MainMenu visible")

	main_node.show_settings()
	_assert_true(main_node.current_screen == Main.Screen.SETTINGS and main_node.settings_screen.visible, "Should switch to SETTINGS")

	main_node.show_high_scores()
	_assert_true(main_node.current_screen == Main.Screen.HIGH_SCORES and main_node.high_score_screen.visible, "Should switch to HIGH_SCORES")

	main_node.show_game()
	_assert_true(main_node.current_screen == Main.Screen.GAME and main_node.game_scene.visible, "Should switch to GAME")
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.READY, "New game should start in READY state")
	_assert_true(main_node.game_scene.ready_overlay.visible, "ReadyOverlay should be visible in READY state")

	# Verify real Android InputEventScreenTouch + InputEventScreenDrag swipe starts READY -> PLAYING and turns snake.
	var touch_down := InputEventScreenTouch.new()
	touch_down.pressed = true
	touch_down.position = Vector2(180, 260)
	main_node.game_scene._input(touch_down)

	var touch_drag := InputEventScreenDrag.new()
	touch_drag.position = Vector2(180, 210) # Swipe UP (50px)
	main_node.game_scene._input(touch_drag)

	var touch_up := InputEventScreenTouch.new()
	touch_up.pressed = false
	touch_up.position = Vector2(180, 210)
	main_node.game_scene._input(touch_up)

	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PLAYING, "Touch swipe should transition READY -> PLAYING")
	_assert_true(main_node.game_scene.session.snake.get_next_direction() == Vector2i.UP, "Touch swipe UP should queue UP direction")
	_assert_true(not main_node.game_scene.ready_overlay.visible, "ReadyOverlay should hide when PLAYING")

	# Pause & resume
	main_node.game_scene.toggle_pause()
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PAUSED, "toggle_pause should enter PAUSED")
	_assert_true(main_node.game_scene.pause_overlay.visible, "PauseOverlay should be visible when PAUSED")

	main_node.game_scene.toggle_pause()
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PLAYING, "toggle_pause should resume PLAYING")
	_assert_true(not main_node.game_scene.pause_overlay.visible, "PauseOverlay should hide on resume")

	# Verify CircularDpad continuous 360-degree hold-and-roll motion emits all 4 directions without releasing.
	var dpad: CircularDpad = main_node.game_scene.circular_dpad
	_assert_true(dpad != null and dpad.custom_minimum_size.x >= 150.0, "CircularDpad must exist with >=150px diameter")
	dpad.size = dpad.custom_minimum_size
	var recorded_dirs: Array[Vector2i] = []
	var cb := func(d: Vector2i) -> void: recorded_dirs.append(d)
	dpad.direction_changed.connect(cb)

	var d_down := InputEventScreenTouch.new()
	d_down.index = 0
	d_down.pressed = true
	d_down.position = Vector2(92, 20) # UP
	dpad._gui_input(d_down)

	for drag_pt in [Vector2(164, 92), Vector2(92, 164), Vector2(20, 92), Vector2(92, 20)]:
		var d_drag := InputEventScreenDrag.new()
		d_drag.index = 0
		d_drag.position = drag_pt
		dpad._gui_input(d_drag)

	var d_up := InputEventScreenTouch.new()
	d_up.index = 0
	d_up.pressed = false
	d_up.position = Vector2(92, 20)
	dpad._gui_input(d_up)
	dpad.direction_changed.disconnect(cb)

	_assert_true(
		recorded_dirs == [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP],
		"Circular D-pad hold-and-roll must emit UP->RIGHT->DOWN->LEFT->UP continuously"
	)

	# Verify minimum 44px tap target height on all interactive buttons across screens.
	var buttons_to_check: Array[Button] = [
		main_node.main_menu.play_button,
		main_node.main_menu.high_scores_button,
		main_node.main_menu.settings_button,
		main_node.settings_screen.difficulty_button,
		main_node.settings_screen.walls_button,
		main_node.settings_screen.dpad_button,
		main_node.settings_screen.sfx_button,
		main_node.settings_screen.music_button,
		main_node.settings_screen.back_button,
		main_node.high_score_screen.back_button,
		main_node.game_scene.pause_button,
		main_node.game_scene.restart_button,
		main_node.game_scene.resume_button,
		main_node.game_scene.pause_restart_button,
		main_node.game_scene.pause_menu_button,
		main_node.game_scene.play_again_button,
		main_node.game_scene.game_over_menu_button,
	]
	for btn in buttons_to_check:
		_assert_true(btn.custom_minimum_size.y >= 44.0, "Button %s must meet >=44px tap target height" % btn.name)
	_assert_true(main_node.game_scene.pause_button.icon != null, "PauseButton must have a pixel icon")
	_assert_true(main_node.game_scene.restart_button.icon != null, "RestartButton must have a pixel icon")
