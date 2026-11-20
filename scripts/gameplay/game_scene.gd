class_name GameScene
extends Control
## Main game scene hosting the monochrome LCD frame, HUD strip, BoardRenderer, and gameplay loop.

@onready var board_renderer: BoardRenderer = %BoardRenderer
@onready var score_label: Label = %ScoreLabel

var grid: GridSystem
var session: SnakeGameSession
var move_interval: float = GameConfig.DEFAULT_MOVE_INTERVAL
var _move_accumulator: float = 0.0


func _ready() -> void:
	grid = GridSystem.new(
		GameConfig.GRID_COLUMNS,
		GameConfig.GRID_ROWS,
		GameConfig.CELL_SIZE
	)
	session = SnakeGameSession.new(grid, false)
	board_renderer.set_grid(grid)
	_sync_view()


func _unhandled_input(event: InputEvent) -> void:
	if session == null:
		return

	if session.state == SnakeGameSession.State.GAME_OVER:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R):
			restart_game()
		return

	if event.is_action_pressed("move_up"):
		request_direction(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		request_direction(Vector2i.DOWN)
	elif event.is_action_pressed("move_left"):
		request_direction(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		request_direction(Vector2i.RIGHT)


func _process(delta: float) -> void:
	if session == null or session.state != SnakeGameSession.State.PLAYING:
		return

	# Cap delta so tab-switching or frame hitches never burst multiple ticks at once.
	_move_accumulator += minf(delta, move_interval * 2.0)
	while _move_accumulator >= move_interval:
		_move_accumulator -= move_interval
		var result: SnakeGameSession.TickResult = session.tick()
		_sync_view(result)
		if session.state != SnakeGameSession.State.PLAYING:
			break


func request_direction(new_direction: Vector2i) -> bool:
	if session == null:
		return false
	return session.request_direction(new_direction)


func restart_game() -> void:
	_move_accumulator = 0.0
	session.reset(session.wrap_walls, true)
	_sync_view()


func _sync_view(last_result: SnakeGameSession.TickResult = SnakeGameSession.TickResult.NONE) -> void:
	board_renderer.set_snake_cells(session.snake.segments, session.snake.direction)
	board_renderer.set_food_cell(session.food_cell)

	if session.state == SnakeGameSession.State.GAME_OVER:
		if last_result == SnakeGameSession.TickResult.BOARD_CLEARED:
			score_label.text = "YOU WIN! (ENTER)"
		else:
			score_label.text = "GAME OVER (ENTER)"
	else:
		# shortcut: Phase 5 replaces raw food count with full scoring and high-score persistence.
		score_label.text = "EATEN: %04d" % session.food_eaten
