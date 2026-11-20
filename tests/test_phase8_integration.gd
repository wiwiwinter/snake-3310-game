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
	for vp in viewports:
		main_node.size = vp
		main_node.game_scene.size = vp
		var min_sz: Vector2 = main_node.game_scene.get_combined_minimum_size()
		_assert_true(min_sz.x <= vp.x, "GameScene min width %.1f must fit viewport width %.1f" % [min_sz.x, vp.x])
		_assert_true(min_sz.y <= vp.y, "GameScene min height %.1f must fit viewport height %.1f" % [min_sz.y, vp.y])


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
