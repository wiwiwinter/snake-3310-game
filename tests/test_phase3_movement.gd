extends SceneTree
## Automated headless tests for Phase 3 (SnakeController movement, input buffer, 180-degree guard).

var _failures: int = 0


func _init() -> void:
	_test_basic_step_and_tail_follow()
	_test_reject_180_reversal_and_duplicates()
	_test_rapid_two_step_turn_buffer()
	_test_wraparound_edges()
	_test_invalid_direction_rejected()

	if _failures == 0:
		print("PASS: All Phase 3 snake movement tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 3 test(s) failed." % _failures)
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		printerr("  [FAIL] " + message)
		_failures += 1


func _test_basic_step_and_tail_follow() -> void:
	var grid := GridSystem.new(16, 20, 18)
	var snake := SnakeController.new([Vector2i(6, 10), Vector2i(5, 10), Vector2i(4, 10)], Vector2i.RIGHT)

	snake.step(grid)
	_assert_true(snake.segments == [Vector2i(7, 10), Vector2i(6, 10), Vector2i(5, 10)], "Snake should advance RIGHT by 1 cell")

	_assert_true(snake.queue_direction(Vector2i.DOWN), "Queueing DOWN from RIGHT should succeed")
	snake.step(grid)
	_assert_true(snake.segments == [Vector2i(7, 11), Vector2i(7, 10), Vector2i(6, 10)], "Snake should turn DOWN cleanly")


func _test_reject_180_reversal_and_duplicates() -> void:
	var grid := GridSystem.new(16, 20, 18)
	var snake := SnakeController.new([Vector2i(6, 10), Vector2i(5, 10)], Vector2i.RIGHT)

	_assert_true(not snake.queue_direction(Vector2i.LEFT), "Immediate 180-degree LEFT from RIGHT must be rejected")
	_assert_true(not snake.queue_direction(Vector2i.RIGHT), "Duplicate RIGHT must be rejected")

	snake.step(grid)
	_assert_true(snake.get_head() == Vector2i(7, 10), "Snake should keep moving RIGHT after rejected inputs")


func _test_rapid_two_step_turn_buffer() -> void:
	var grid := GridSystem.new(16, 20, 18)
	var snake := SnakeController.new([Vector2i(6, 10), Vector2i(5, 10), Vector2i(4, 10)], Vector2i.RIGHT)

	# Rapid UP then LEFT within a single tick must buffer both turns safely instead of reversing into body.
	_assert_true(snake.queue_direction(Vector2i.UP), "First buffered turn UP should succeed")
	_assert_true(snake.queue_direction(Vector2i.LEFT), "Second buffered turn LEFT (after UP) should succeed")
	_assert_true(not snake.queue_direction(Vector2i.DOWN), "Third queued input should be dropped at buffer cap")

	snake.step(grid)
	_assert_true(snake.direction == Vector2i.UP, "Tick 1 should execute UP")
	_assert_true(snake.get_head() == Vector2i(6, 9), "Tick 1 head should be (6,9)")

	snake.step(grid)
	_assert_true(snake.direction == Vector2i.LEFT, "Tick 2 should execute LEFT")
	_assert_true(snake.get_head() == Vector2i(5, 9), "Tick 2 head should be (5,9)")


func _test_wraparound_edges() -> void:
	var grid := GridSystem.new(16, 20, 18)
	var snake := SnakeController.new([Vector2i(15, 0), Vector2i(14, 0)], Vector2i.RIGHT)
	snake.step(grid, false, true)
	_assert_true(snake.get_head() == Vector2i(0, 0), "Right edge should wrap to x=0")

	snake.queue_direction(Vector2i.UP)
	snake.step(grid, false, true)
	_assert_true(snake.get_head() == Vector2i(0, 19), "Top edge should wrap to y=19")


func _test_invalid_direction_rejected() -> void:
	var snake := SnakeController.new([Vector2i(5, 5)], Vector2i.RIGHT)
	_assert_true(not snake.queue_direction(Vector2i.ZERO), "ZERO vector must be rejected")
	_assert_true(not snake.queue_direction(Vector2i(1, 1)), "Diagonal vector must be rejected")
