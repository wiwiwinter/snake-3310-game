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

	var reloaded := ScoreManager.new(TEST_SAVE_PATH)
	_assert_true(reloaded.wrap_walls == true, "wrap_walls=true must persist")
	_assert_true(reloaded.sfx_enabled == false, "sfx_enabled=false must persist")
	_assert_true(reloaded.music_enabled == false, "music_enabled=false must persist")


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

	# First directional input transitions READY -> PLAYING
	_assert_true(main_node.game_scene.request_direction(Vector2i.UP), "Directional input should start game from READY")
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PLAYING, "Game should transition to PLAYING")
	_assert_true(not main_node.game_scene.ready_overlay.visible, "ReadyOverlay should hide when PLAYING")

	# Pause & resume
	main_node.game_scene.toggle_pause()
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PAUSED, "toggle_pause should enter PAUSED")
	_assert_true(main_node.game_scene.pause_overlay.visible, "PauseOverlay should be visible when PAUSED")

	main_node.game_scene.toggle_pause()
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PLAYING, "toggle_pause should resume PLAYING")
	_assert_true(not main_node.game_scene.pause_overlay.visible, "PauseOverlay should hide on resume")

	# Verify minimum 44px tap target height on all interactive buttons across screens.
	var buttons_to_check: Array[Button] = [
		main_node.main_menu.play_button,
		main_node.main_menu.high_scores_button,
		main_node.main_menu.settings_button,
		main_node.settings_screen.difficulty_button,
		main_node.settings_screen.walls_button,
		main_node.settings_screen.sfx_button,
		main_node.settings_screen.music_button,
		main_node.settings_screen.back_button,
		main_node.high_score_screen.back_button,
		main_node.game_scene.up_button,
		main_node.game_scene.down_button,
		main_node.game_scene.left_button,
		main_node.game_scene.right_button,
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
