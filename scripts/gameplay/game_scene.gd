class_name GameScene
extends Control
## Main game scene hosting the monochrome LCD frame, HUD strip, and BoardRenderer.

@onready var board_renderer: BoardRenderer = %BoardRenderer
@onready var score_label: Label = %ScoreLabel

var grid: GridSystem


func _ready() -> void:
	grid = GridSystem.new(
		GameConfig.GRID_COLUMNS,
		GameConfig.GRID_ROWS,
		GameConfig.CELL_SIZE
	)
	_initialize_board_preview()


func _initialize_board_preview() -> void:
	board_renderer.set_grid(grid)
	board_renderer.set_snake_cells(GameConfig.INITIAL_SNAKE_CELLS, GameConfig.INITIAL_DIRECTION)
	board_renderer.set_food_cell(GameConfig.INITIAL_FOOD_CELL)
	score_label.text = "SCORE: 0000"
