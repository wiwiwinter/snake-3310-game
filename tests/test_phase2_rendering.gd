extends SceneTree
## Automated headless verification for Phase 2 (GridSystem, BoardRenderer, GameScene).

var _failures: int = 0


func _init() -> void:
	_test_grid_system()
	_test_game_scene_instantiation()

	if _failures == 0:
		print("PASS: All Phase 2 rendering & grid tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 2 test(s) failed." % _failures)
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		printerr("  [FAIL] " + message)
		_failures += 1


func _test_grid_system() -> void:
	var grid := GridSystem.new(16, 20, 18)
	_assert_true(grid.get_board_pixel_size() == Vector2(288, 360), "Board pixel size should be 288x360")
	_assert_true(grid.get_total_cells() == 320, "Total cells should be 320")
	_assert_true(grid.is_within_bounds(Vector2i(0, 0)), "(0,0) should be in bounds")
	_assert_true(grid.is_within_bounds(Vector2i(15, 19)), "(15,19) should be in bounds")
	_assert_true(not grid.is_within_bounds(Vector2i(-1, 0)), "(-1,0) should be out of bounds")
	_assert_true(not grid.is_within_bounds(Vector2i(16, 0)), "(16,0) should be out of bounds")
	_assert_true(not grid.is_within_bounds(Vector2i(0, 20)), "(0,20) should be out of bounds")
	_assert_true(grid.wrap_cell(Vector2i(-1, 20)) == Vector2i(15, 0), "Wrap (-1,20) should become (15,0)")
	_assert_true(grid.wrap_cell(Vector2i(16, -1)) == Vector2i(0, 19), "Wrap (16,-1) should become (0,19)")
	_assert_true(grid.grid_to_local(Vector2i(2, 3)) == Vector2(36, 54), "grid_to_local(2,3) should be (36,54)")
	_assert_true(grid.grid_to_center(Vector2i(0, 0)) == Vector2(9, 9), "grid_to_center(0,0) should be (9,9)")


func _test_game_scene_instantiation() -> void:
	var packed: PackedScene = load("res://scenes/game/game_scene.tscn")
	_assert_true(packed != null, "game_scene.tscn should load cleanly")
	if packed == null:
		return

	var instance: Node = packed.instantiate()
	root.add_child(instance)
	var board: BoardRenderer = instance.get_node("%BoardRenderer") as BoardRenderer
	_assert_true(board != null, "GameScene should contain %BoardRenderer")
	if board != null:
		_assert_true(board.custom_minimum_size == Vector2(288, 360), "BoardRenderer minimum size should be 288x360")
	instance.free()
