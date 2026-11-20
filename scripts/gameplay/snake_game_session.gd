class_name SnakeGameSession
extends RefCounted
## Core Snake gameplay rules: food spawning, consumption/growth, wall & self collision, and game state.

enum State {
	READY,
	PLAYING,
	PAUSED,
	GAME_OVER,
}

enum TickResult {
	NONE,
	MOVED,
	ATE_FOOD,
	GAME_OVER_WALL,
	GAME_OVER_SELF,
	BOARD_CLEARED,
}

var grid: GridSystem
var snake: SnakeController
var food_cell: Vector2i = Vector2i(-1, -1)
var wrap_walls: bool = false
var state: State = State.PLAYING
var food_eaten: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(
	p_grid: GridSystem = null,
	p_wrap_walls: bool = false,
	p_seed: int = 0
) -> void:
	grid = p_grid if p_grid != null else GridSystem.new()
	wrap_walls = p_wrap_walls
	if p_seed != 0:
		_rng.seed = p_seed
	else:
		_rng.randomize()
	snake = SnakeController.new()
	reset(wrap_walls, true)


func reset(p_wrap_walls: bool = wrap_walls, start_immediately: bool = true) -> void:
	wrap_walls = p_wrap_walls
	snake.reset(GameConfig.INITIAL_SNAKE_CELLS, GameConfig.INITIAL_DIRECTION)
	food_eaten = 0
	state = State.PLAYING if start_immediately else State.READY
	spawn_food()


func request_direction(new_direction: Vector2i) -> bool:
	if state != State.PLAYING:
		return false
	return snake.queue_direction(new_direction)


func spawn_food() -> Vector2i:
	var occupied: Dictionary = {}
	for seg in snake.segments:
		occupied[seg] = true

	var empty_cells: Array[Vector2i] = []
	for y in range(grid.rows):
		for x in range(grid.columns):
			var cell := Vector2i(x, y)
			if not occupied.has(cell):
				empty_cells.append(cell)

	if empty_cells.is_empty():
		food_cell = Vector2i(-1, -1)
		return food_cell

	food_cell = empty_cells[_rng.randi_range(0, empty_cells.size() - 1)]
	return food_cell


func tick() -> TickResult:
	if state != State.PLAYING:
		return TickResult.NONE

	var candidate: Vector2i = snake.get_head() + snake.get_next_direction()
	if wrap_walls:
		candidate = grid.wrap_cell(candidate)
	elif not grid.is_within_bounds(candidate):
		state = State.GAME_OVER
		return TickResult.GAME_OVER_WALL

	var will_grow: bool = (candidate == food_cell)
	if _collides_with_body(candidate, will_grow):
		state = State.GAME_OVER
		return TickResult.GAME_OVER_SELF

	snake.step(grid, will_grow, wrap_walls)

	if will_grow:
		food_eaten += 1
		if spawn_food() == Vector2i(-1, -1):
			state = State.GAME_OVER
			return TickResult.BOARD_CLEARED
		return TickResult.ATE_FOOD

	return TickResult.MOVED


func _collides_with_body(candidate: Vector2i, will_grow: bool) -> bool:
	# Moving into the current tail is valid when not growing because the tail vacates on this tick.
	var check_count: int = snake.segments.size() if will_grow else maxi(0, snake.segments.size() - 1)
	for i in range(check_count):
		if snake.segments[i] == candidate:
			return true
	return false
