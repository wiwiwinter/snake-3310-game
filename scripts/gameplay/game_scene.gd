class_name GameScene
extends Control
## Main game scene hosting the monochrome LCD frame, HUD strip, BoardRenderer, and movement loop.

@onready var board_renderer: BoardRenderer = %BoardRenderer
@onready var score_label: Label = %ScoreLabel

var grid: GridSystem
var snake: SnakeController
var move_interval: float = GameConfig.DEFAULT_MOVE_INTERVAL
var _move_accumulator: float = 0.0


func _ready() -> void:
	grid = GridSystem.new(
		GameConfig.GRID_COLUMNS,
		GameConfig.GRID_ROWS,
		GameConfig.CELL_SIZE
	)
	snake = SnakeController.new(
		GameConfig.INITIAL_SNAKE_CELLS,
		GameConfig.INITIAL_DIRECTION
	)
	_initialize_board()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		request_direction(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		request_direction(Vector2i.DOWN)
	elif event.is_action_pressed("move_left"):
		request_direction(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		request_direction(Vector2i.RIGHT)


func _process(delta: float) -> void:
	# Cap delta so tab-switching or frame hitches never burst multiple ticks at once.
	_move_accumulator += minf(delta, move_interval * 2.0)
	while _move_accumulator >= move_interval:
		_move_accumulator -= move_interval
		_step_movement()


func request_direction(new_direction: Vector2i) -> bool:
	if snake == null:
		return false
	return snake.queue_direction(new_direction)


func _initialize_board() -> void:
	board_renderer.set_grid(grid)
	board_renderer.set_snake_cells(snake.segments, snake.direction)
	board_renderer.set_food_cell(GameConfig.INITIAL_FOOD_CELL)
	score_label.text = "SCORE: 0000"


func _step_movement() -> void:
	# shortcut: Phase 3 wraps walls so continuous movement is testable before Phase 4 collision rules.
	snake.step(grid, false, true)
	board_renderer.set_snake_cells(snake.segments, snake.direction)
