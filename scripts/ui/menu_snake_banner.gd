class_name MenuSnakeBanner
extends Control
## Animated monochrome LCD banner strip showing a pixel snake chasing food across a dot-matrix track.

const CELL: int = 12
const SNAKE_LEN: int = 7

var _head_col: int = 4
var _food_col: int = 16
var _step_timer: float = 0.0
var _pulse: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(240, 28)
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	_step_timer += delta
	if _step_timer >= 0.14:
		_step_timer = 0.0
		_pulse = not _pulse
		var cols: int = maxi(10, int(size.x / float(CELL)))
		_head_col = (_head_col + 1) % cols
		if _head_col == _food_col:
			_food_col = (_head_col + cols / 2) % cols
		queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Recessed dot-matrix track strip
	draw_rect(Rect2(Vector2.ZERO, Vector2(w, h)), GameConfig.COLOR_LCD_LIGHT, true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(w, h)), GameConfig.COLOR_LCD_DEEP, false, 2.0)

	var cols: int = maxi(10, int(w / float(CELL)))
	var y_origin: float = floor((h - float(CELL)) * 0.5)

	# Draw classic 4-dot diamond food
	var fx: float = float(_food_col % cols) * float(CELL)
	var u: float = 3.0
	draw_rect(Rect2(fx + u, y_origin + 1.0, u * 2.0, u), GameConfig.COLOR_LCD_DEEP, true)
	draw_rect(Rect2(fx + u, y_origin + u * 3.0 - 1.0, u * 2.0, u), GameConfig.COLOR_LCD_DEEP, true)
	draw_rect(Rect2(fx + 1.0, y_origin + u, u, u * 2.0), GameConfig.COLOR_LCD_DEEP, true)
	draw_rect(Rect2(fx + u * 3.0 - 1.0, y_origin + u, u, u * 2.0), GameConfig.COLOR_LCD_DEEP, true)
	if _pulse:
		draw_rect(Rect2(fx + u + 1.0, y_origin + u + 1.0, u, u), GameConfig.COLOR_LCD_DARK, true)

	# Draw segmented snake moving right
	for i in range(SNAKE_LEN):
		var col: int = posmod(_head_col - i, cols)
		var x: float = float(col * CELL)
		if i == 0:
			draw_rect(Rect2(x + 1.0, y_origin + 1.0, CELL - 2.0, CELL - 2.0), GameConfig.COLOR_LCD_DEEP, true)
			draw_rect(Rect2(x + CELL - 4.0, y_origin + 3.0, 2.0, 2.0), GameConfig.COLOR_LCD_BG, true)
			draw_rect(Rect2(x + CELL - 4.0, y_origin + CELL - 5.0, 2.0, 2.0), GameConfig.COLOR_LCD_BG, true)
		elif i == SNAKE_LEN - 1:
			draw_rect(Rect2(x + 3.0, y_origin + 3.0, CELL - 6.0, CELL - 6.0), GameConfig.COLOR_LCD_DEEP, true)
		else:
			draw_rect(Rect2(x + 2.0, y_origin + 2.0, CELL - 4.0, CELL - 4.0), GameConfig.COLOR_LCD_DEEP, true)
			draw_rect(Rect2(x + 4.0, y_origin + 4.0, CELL - 8.0, CELL - 8.0), GameConfig.COLOR_LCD_DARK, true)
