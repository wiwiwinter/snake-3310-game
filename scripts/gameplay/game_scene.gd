class_name GameScene
extends Control
## Main game scene hosting the monochrome LCD frame, HUD strip, BoardRenderer, scoring, and gameplay loop.

@onready var board_renderer: BoardRenderer = %BoardRenderer
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var difficulty_label: Label = %DifficultyLabel

var grid: GridSystem
var session: SnakeGameSession
var score_manager: ScoreManager
var move_interval: float = GameConfig.DEFAULT_MOVE_INTERVAL
var _move_accumulator: float = 0.0


func _ready() -> void:
	grid = GridSystem.new(
		GameConfig.GRID_COLUMNS,
		GameConfig.GRID_ROWS,
		GameConfig.CELL_SIZE
	)
	score_manager = ScoreManager.new()
	move_interval = score_manager.get_move_interval()
	session = SnakeGameSession.new(grid, false)
	board_renderer.set_grid(grid)
	_sync_view()


func _unhandled_input(event: InputEvent) -> void:
	if session == null:
		return

	# shortcut: temporary 1/2/3 desktop keys to test difficulty speeds before Phase 6 Settings UI.
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			set_difficulty(GameConfig.Difficulty.EASY)
			return
		elif event.keycode == KEY_2:
			set_difficulty(GameConfig.Difficulty.NORMAL)
			return
		elif event.keycode == KEY_3:
			set_difficulty(GameConfig.Difficulty.HARD)
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
		if result == SnakeGameSession.TickResult.ATE_FOOD or result == SnakeGameSession.TickResult.BOARD_CLEARED:
			score_manager.add_points()
		_sync_view(result)
		if session.state != SnakeGameSession.State.PLAYING:
			break


func request_direction(new_direction: Vector2i) -> bool:
	if session == null:
		return false
	return session.request_direction(new_direction)


func set_difficulty(new_difficulty: GameConfig.Difficulty) -> void:
	if score_manager == null:
		return
	score_manager.set_difficulty(new_difficulty)
	move_interval = score_manager.get_move_interval()
	_sync_view()


func restart_game() -> void:
	_move_accumulator = 0.0
	score_manager.reset_score()
	session.reset(session.wrap_walls, true)
	_sync_view()


func _sync_view(last_result: SnakeGameSession.TickResult = SnakeGameSession.TickResult.NONE) -> void:
	if session == null or score_manager == null or board_renderer == null:
		return
	board_renderer.set_snake_cells(session.snake.segments, session.snake.direction)
	board_renderer.set_food_cell(session.food_cell)

	high_score_label.text = "HI %04d" % score_manager.high_score
	if session.state == SnakeGameSession.State.GAME_OVER:
		score_label.text = "SCR %04d" % score_manager.current_score
		difficulty_label.text = "WIN! [R]" if last_result == SnakeGameSession.TickResult.BOARD_CLEARED else "OVER [R]"
	else:
		score_label.text = "SCR %04d" % score_manager.current_score
		difficulty_label.text = GameConfig.get_difficulty_name(score_manager.difficulty)
