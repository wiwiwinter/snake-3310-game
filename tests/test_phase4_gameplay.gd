extends SceneTree
## Automated headless tests for Phase 4 (food spawning, growth, wall/self collision, restart).

var _failures: int = 0


func _init() -> void:
	_test_food_spawns_on_unoccupied_cell()
	_test_eat_food_grows_snake()
	_test_solid_wall_collision_game_over()
	_test_wraparound_wall_mode()
	_test_self_collision_game_over()
	_test_moving_into_vacating_tail_allowed()
	_test_board_cleared_and_restart()

	if _failures == 0:
		print("PASS: All Phase 4 food & collision tests succeeded.")
		quit(0)
	else:
		printerr("FAIL: %d Phase 4 test(s) failed." % _failures)
		quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		printerr("  [FAIL] " + message)
		_failures += 1


func _test_food_spawns_on_unoccupied_cell() -> void:
	var grid := GridSystem.new(3, 3, 18)
	var session := SnakeGameSession.new(grid, false, 42)
	# Occupy 8 of 9 cells, leaving only (2, 2) free.
	session.snake.reset([
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(0, 2), Vector2i(1, 2),
	], Vector2i.RIGHT)
	var spawned := session.spawn_food()
	_assert_true(spawned == Vector2i(2, 2), "Food must spawn on the single unoccupied cell (2,2)")


func _test_eat_food_grows_snake() -> void:
	var grid := GridSystem.new(10, 10, 18)
	var session := SnakeGameSession.new(grid, false, 123)
	session.snake.reset([Vector2i(4, 5), Vector2i(3, 5), Vector2i(2, 5)], Vector2i.RIGHT)
	session.food_cell = Vector2i(5, 5)

	var res := session.tick()
	_assert_true(res == SnakeGameSession.TickResult.ATE_FOOD, "Stepping onto food must return ATE_FOOD")
	_assert_true(session.snake.segments.size() == 4, "Snake length must grow from 3 to 4")
	_assert_true(session.food_eaten == 1, "food_eaten must increment to 1")
	_assert_true(grid.is_within_bounds(session.food_cell), "New food must be within bounds")
	_assert_true(session.food_cell not in session.snake.segments, "New food must not spawn inside snake")


func _test_solid_wall_collision_game_over() -> void:
	var grid := GridSystem.new(6, 6, 18)
	var session := SnakeGameSession.new(grid, false, 7)
	session.snake.reset([Vector2i(5, 2), Vector2i(4, 2)], Vector2i.RIGHT)
	session.food_cell = Vector2i(0, 0)

	var res := session.tick()
	_assert_true(res == SnakeGameSession.TickResult.GAME_OVER_WALL, "Hitting solid wall must return GAME_OVER_WALL")
	_assert_true(session.state == SnakeGameSession.State.GAME_OVER, "State must transition to GAME_OVER")
	_assert_true(session.tick() == SnakeGameSession.TickResult.NONE, "Ticks after GAME_OVER must do nothing")


func _test_wraparound_wall_mode() -> void:
	var grid := GridSystem.new(6, 6, 18)
	var session := SnakeGameSession.new(grid, true, 7)
	session.snake.reset([Vector2i(5, 2), Vector2i(4, 2)], Vector2i.RIGHT)
	session.food_cell = Vector2i(3, 3)

	var res := session.tick()
	_assert_true(res == SnakeGameSession.TickResult.MOVED, "Wraparound mode must move across edge")
	_assert_true(session.snake.get_head() == Vector2i(0, 2), "Head must wrap to (0,2)")
	_assert_true(session.state == SnakeGameSession.State.PLAYING, "State must remain PLAYING")


func _test_self_collision_game_over() -> void:
	var grid := GridSystem.new(10, 10, 18)
	var session := SnakeGameSession.new(grid, false, 99)
	# U-shape where moving DOWN hits own body segment (5, 5).
	session.snake.reset([
		Vector2i(5, 4), Vector2i(6, 4), Vector2i(6, 5),
		Vector2i(5, 5), Vector2i(4, 5),
	], Vector2i.LEFT)
	session.food_cell = Vector2i(0, 0)
	session.request_direction(Vector2i.DOWN)

	var res := session.tick()
	_assert_true(res == SnakeGameSession.TickResult.GAME_OVER_SELF, "Hitting body must return GAME_OVER_SELF")
	_assert_true(session.state == SnakeGameSession.State.GAME_OVER, "State must become GAME_OVER")


func _test_moving_into_vacating_tail_allowed() -> void:
	var grid := GridSystem.new(10, 10, 18)
	var session := SnakeGameSession.new(grid, false, 99)
	# 2x2 closed loop: head at (5,4) moving DOWN into tail at (5,5) while not growing is valid.
	session.snake.reset([
		Vector2i(5, 4), Vector2i(6, 4), Vector2i(6, 5), Vector2i(5, 5),
	], Vector2i.LEFT)
	session.food_cell = Vector2i(0, 0)
	session.request_direction(Vector2i.DOWN)

	var res := session.tick()
	_assert_true(res == SnakeGameSession.TickResult.MOVED, "Moving into vacating tail must be allowed")
	_assert_true(session.snake.get_head() == Vector2i(5, 5), "Head should occupy former tail cell")


func _test_board_cleared_and_restart() -> void:
	var grid := GridSystem.new(2, 2, 18)
	var session := SnakeGameSession.new(grid, false, 1)
	session.snake.reset([Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)], Vector2i.RIGHT)
	session.food_cell = Vector2i(1, 0)

	var res := session.tick()
	_assert_true(res == SnakeGameSession.TickResult.BOARD_CLEARED, "Filling last cell must return BOARD_CLEARED")
	_assert_true(session.food_cell == Vector2i(-1, -1), "No food should remain on full board")
	_assert_true(session.state == SnakeGameSession.State.GAME_OVER, "Board clear should end active session")

	# Verify reset restores playable state on standard grid.
	var std_session := SnakeGameSession.new(GridSystem.new(), false, 1)
	std_session.state = SnakeGameSession.State.GAME_OVER
	std_session.food_eaten = 9
	std_session.reset()
	_assert_true(std_session.state == SnakeGameSession.State.PLAYING, "Reset must restore PLAYING state")
	_assert_true(std_session.food_eaten == 0, "Reset must zero food_eaten")
	_assert_true(std_session.snake.segments == GameConfig.INITIAL_SNAKE_CELLS, "Reset must restore initial snake")
