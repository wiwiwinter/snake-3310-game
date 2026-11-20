extends SceneTree
## Phase 8 integration, multi-resolution portrait layout, Android lifecycle, and performance tests.

const TEST_SAVE_PATH: String = "res://.godot/test_phase8_save.cfg"

var _failures: int = 0
var _main_node: Main
var _ran: bool = false


func _initialize() -> void:
	_cleanup_test_file()
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
		_test_portrait_resolutions(_main_node)
		_test_adaptive_grid_sizing()
		_test_android_safe_area_inset()
		_test_android_lifecycle_and_back_button(_main_node)
		_test_end_to_end_scoring_and_wraparound(_main_node)
		_test_performance_benchmark()
		_main_node.free()
		_main_node = null

	_cleanup_test_file()
	if _failures == 0:
		print("PASS: All Phase 8 integration, layout, lifecycle & performance tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 8 test(s) failed." % _failures)
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


func _test_portrait_resolutions(main_node: Main) -> void:
	# Verify GameScene fits without horizontal or vertical overflow across common portrait Android ratios.
	var viewports: Array[Vector2] = [
		Vector2(360, 640),  # 16:9
		Vector2(360, 780),  # 19.5:9
		Vector2(360, 800),  # 20:9
		Vector2(412, 915),  # Modern tall Android
	]
	main_node.show_game()
	for pad_sz in [GameConfig.DpadSize.SMALL, GameConfig.DpadSize.MEDIUM, GameConfig.DpadSize.LARGE]:
		main_node.score_manager.set_dpad_size(pad_sz)
		main_node.game_scene.start_new_game(false)
		for vp in viewports:
			main_node.size = vp
			main_node.game_scene.size = vp
			var min_sz: Vector2 = main_node.game_scene.get_combined_minimum_size()
			_assert_true(min_sz.x <= vp.x, "GameScene min width %.1f must fit viewport width %.1f (pad=%d)" % [min_sz.x, vp.x, pad_sz])
			_assert_true(min_sz.y <= vp.y, "GameScene min height %.1f must fit viewport height %.1f (pad=%d)" % [min_sz.y, vp.y, pad_sz])
	main_node.score_manager.set_dpad_size(GameConfig.DpadSize.MEDIUM)

	# Verify SettingsScreen also fits compact 360x640 without clipping (ScrollContainer enabled).
	main_node.show_settings()
	main_node.size = Vector2(360, 640)
	main_node.settings_screen.size = Vector2(360, 640)
	var settings_min: Vector2 = main_node.settings_screen.get_combined_minimum_size()
	_assert_true(settings_min.x <= 360.0 and settings_min.y <= 640.0, "SettingsScreen min size %.1fx%.1f must fit 360x640" % [settings_min.x, settings_min.y])


func _test_adaptive_grid_sizing() -> void:
	# Standard 16:9 stage (~316x360) vs tall 20:9 Nothing 3a Lite stage (~316x490)
	var std_params: Vector3i = GameScene.compute_adaptive_grid_params(Vector2(316, 360))
	var tall_params: Vector3i = GameScene.compute_adaptive_grid_params(Vector2(316, 490))
	_assert_true(std_params.x == 16 and tall_params.x == 16, "Columns should stay 16 across portrait screens")
	_assert_true(std_params.z == 19 and tall_params.z == 19, "Cell size should scale to 19px on 316px stage")
	_assert_true(tall_params.y > std_params.y, "Tall 20:9 phone must expand grid rows (%d > %d)" % [tall_params.y, std_params.y])
	_assert_true(tall_params.y * tall_params.z <= 490, "Expanded grid pixel height must fit stage height")


func _test_android_safe_area_inset() -> void:
	# Desktop without cutout -> 0
	var desktop_inset: int = Main.compute_top_safe_inset(Rect2i(0, 0, 360, 640), Vector2i(360, 640), 640.0, false)
	_assert_true(desktop_inset == 0, "Desktop without cutout should have 0 top inset")
	# Android immersive mode reporting 0 -> falls back to 42px punch-hole clearance
	var android_min: int = Main.compute_top_safe_inset(Rect2i(0, 0, 1080, 2392), Vector2i(1080, 2392), 797.0, true)
	_assert_true(android_min >= 42, "Android immersive mode must reserve >=42px for camera punch-hole")
	# Android reporting 135px status/cutout on 2400px screen (~45px at 800px viewport)
	var android_cutout: int = Main.compute_top_safe_inset(Rect2i(0, 135, 1080, 2200), Vector2i(1080, 2400), 800.0, true)
	_assert_true(android_cutout >= 45, "Android reported cutout inset must scale accurately to viewport")
	# Android reporting 90px bottom gesture bar on 2400px screen (~30px at 800px viewport)
	var bottom_inset: int = Main.compute_bottom_safe_inset(Rect2i(0, 135, 1080, 2175), Vector2i(1080, 2400), 800.0)
	_assert_true(bottom_inset == 30, "Android bottom nav inset must scale accurately to 30px (got %d)" % bottom_inset)


func _test_android_lifecycle_and_back_button(main_node: Main) -> void:
	main_node.score_manager = ScoreManager.new(TEST_SAVE_PATH)
	main_node.game_scene.configure(main_node.score_manager, main_node.audio_manager)

	# Back from Settings -> Main Menu
	main_node.show_settings()
	main_node.handle_android_back()
	_assert_true(main_node.current_screen == Main.Screen.MAIN_MENU, "Back in Settings should return to Main Menu")

	# Back from High Scores -> Main Menu
	main_node.show_high_scores()
	main_node.handle_android_back()
	_assert_true(main_node.current_screen == Main.Screen.MAIN_MENU, "Back in High Scores should return to Main Menu")

	# App backgrounding during PLAYING must auto-pause
	main_node.show_game()
	main_node.game_scene.request_direction(Vector2i.RIGHT)
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PLAYING, "Should be PLAYING")
	main_node.game_scene.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PAUSED, "App pause must auto-pause gameplay")

	# Back while PAUSED resumes gameplay
	main_node.handle_android_back()
	_assert_true(main_node.game_scene.session.state == SnakeGameSession.State.PLAYING, "Back while PAUSED should resume")


func _test_end_to_end_scoring_and_wraparound(main_node: Main) -> void:
	main_node.score_manager = ScoreManager.new(TEST_SAVE_PATH)
	main_node.score_manager.set_wrap_walls(true)
	main_node.score_manager.set_difficulty(GameConfig.Difficulty.HARD)
	main_node.game_scene.configure(main_node.score_manager, main_node.audio_manager)
	main_node.show_game()

	_assert_true(main_node.game_scene.session.wrap_walls == true, "GameScene must apply saved wrap_walls setting")
	_assert_true(
		is_equal_approx(main_node.game_scene.move_interval, GameConfig.get_move_interval(GameConfig.Difficulty.HARD)),
		"GameScene must apply saved HARD move interval"
	)


func _test_performance_benchmark() -> void:
	var grid := GridSystem.new(16, 20, 18)
	var session := SnakeGameSession.new(grid, true, 999)
	var start_us: int = Time.get_ticks_usec()
	for i in range(10000):
		if session.state != SnakeGameSession.State.PLAYING:
			session.reset(true, true)
		if i % 17 == 0:
			session.request_direction(Vector2i.DOWN if (i / 17) % 2 == 0 else Vector2i.RIGHT)
		session.tick()
	var elapsed_ms: float = float(Time.get_ticks_usec() - start_us) / 1000.0
	print("BENCHMARK: 10,000 gameplay ticks completed in %.2f ms." % elapsed_ms)
	_assert_true(elapsed_ms < 500.0, "10,000 gameplay ticks should complete well under 500ms")
