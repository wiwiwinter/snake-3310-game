extends SceneTree
## Automated headless tests for Phase 5 (scoring, high-score persistence, and difficulty speed tiers).

const TEST_SAVE_PATH: String = "res://.godot/test_phase5_save.cfg"

var _failures: int = 0


func _init() -> void:
	_cleanup_test_file()
	_test_score_increment_and_reset()
	_test_high_score_persistence_and_per_difficulty()
	_test_corrupt_save_fallback()
	_test_difficulty_speeds_and_scene_sync()
	_cleanup_test_file()

	if _failures == 0:
		print("PASS: All Phase 5 scoring & difficulty tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 5 test(s) failed." % _failures)
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		printerr("  [FAIL] " + message)
		_failures += 1


func _cleanup_test_file() -> void:
	var abs_path: String = ProjectSettings.globalize_path(TEST_SAVE_PATH)
	if FileAccess.file_exists(abs_path):
		DirAccess.remove_absolute(abs_path)


func _test_score_increment_and_reset() -> void:
	_cleanup_test_file()
	var mgr := ScoreManager.new(TEST_SAVE_PATH)
	_assert_true(mgr.current_score == 0, "Initial score must be 0")
	_assert_true(mgr.high_score == 0, "Initial high score must be 0")

	_assert_true(mgr.add_points(), "First food should set a new high score")
	_assert_true(mgr.current_score == GameConfig.POINTS_PER_FOOD, "Score should increment by POINTS_PER_FOOD")
	_assert_true(mgr.high_score == GameConfig.POINTS_PER_FOOD, "High score should match current score")

	mgr.reset_score()
	_assert_true(mgr.current_score == 0, "Reset should zero current score")
	_assert_true(mgr.high_score == GameConfig.POINTS_PER_FOOD, "Reset must preserve high score")


func _test_high_score_persistence_and_per_difficulty() -> void:
	_cleanup_test_file()
	var mgr := ScoreManager.new(TEST_SAVE_PATH)
	mgr.set_difficulty(GameConfig.Difficulty.HARD)
	mgr.add_points(30)

	# Reload from disk into a fresh ScoreManager instance.
	var reloaded := ScoreManager.new(TEST_SAVE_PATH)
	_assert_true(reloaded.high_score == 30, "Reloaded overall high_score must be 30")
	_assert_true(reloaded.get_high_score_for(GameConfig.Difficulty.HARD) == 30, "Reloaded HARD high score must be 30")
	_assert_true(reloaded.get_high_score_for(GameConfig.Difficulty.EASY) == 0, "EASY high score should remain 0")
	_assert_true(reloaded.difficulty == GameConfig.Difficulty.HARD, "Saved difficulty HARD should persist")


func _test_corrupt_save_fallback() -> void:
	var abs_path: String = ProjectSettings.globalize_path(TEST_SAVE_PATH)
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f != null:
		f.store_string("not valid config [[[ broken")
		f.close()

	var mgr := ScoreManager.new(TEST_SAVE_PATH)
	_assert_true(mgr.high_score == 0, "Corrupt save should safely fall back to high_score=0")
	_assert_true(mgr.difficulty == GameConfig.Difficulty.NORMAL, "Corrupt save should fall back to NORMAL")


func _test_difficulty_speeds_and_scene_sync() -> void:
	var easy_i: float = GameConfig.get_move_interval(GameConfig.Difficulty.EASY)
	var normal_i: float = GameConfig.get_move_interval(GameConfig.Difficulty.NORMAL)
	var hard_i: float = GameConfig.get_move_interval(GameConfig.Difficulty.HARD)
	_assert_true(easy_i > normal_i and normal_i > hard_i, "Intervals must satisfy EASY > NORMAL > HARD")

	var packed: PackedScene = load("res://scenes/game/game_scene.tscn")
	var instance: GameScene = packed.instantiate() as GameScene
	root.add_child(instance)
	instance.score_manager = ScoreManager.new(TEST_SAVE_PATH)
	instance.set_difficulty(GameConfig.Difficulty.HARD)
	_assert_true(is_equal_approx(instance.move_interval, hard_i), "GameScene move_interval must match HARD speed")
	instance.free()
