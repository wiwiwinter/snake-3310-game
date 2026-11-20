class_name BoardRenderer
extends Control
## Renders the monochrome LCD playfield grid, snake segments, and food item.

@export var show_grid_lines: bool = true

var _grid: GridSystem = GridSystem.new()
var _snake_cells: Array[Vector2i] = []
var _snake_direction: Vector2i = GameConfig.INITIAL_DIRECTION
var _food_cell: Vector2i = Vector2i(-1, -1)
var _flash_timer: float = 0.0
var _flash_is_collision: bool = false
var _pulse_time: float = 0.0
var _pulse_on: bool = false


func _ready() -> void:
	_update_board_size()
	queue_redraw()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var needs_redraw: bool = false
	if _flash_timer > 0.0:
		_flash_timer = maxf(0.0, _flash_timer - delta)
		needs_redraw = true

	# Restrained 2-state retro LCD food pulse so the target stands out cleanly.
	_pulse_time += delta
	if _pulse_time >= 0.45:
		_pulse_time = 0.0
		_pulse_on = not _pulse_on
		needs_redraw = true

	if needs_redraw:
		queue_redraw()


func trigger_eat_flash() -> void:
	_flash_is_collision = false
	_flash_timer = 0.12
	queue_redraw()


func trigger_collision_flash() -> void:
	_flash_is_collision = true
	_flash_timer = 0.24
	queue_redraw()


func set_grid(grid: GridSystem) -> void:
	_grid = grid
	_update_board_size()
	queue_redraw()


func set_snake_cells(cells: Array[Vector2i], direction: Vector2i = Vector2i.RIGHT) -> void:
	_snake_cells = cells.duplicate()
	_snake_direction = direction
	queue_redraw()


func set_food_cell(cell: Vector2i) -> void:
	_food_cell = cell
	queue_redraw()


func _update_board_size() -> void:
	if _grid == null:
		return
	var pixel_size: Vector2 = _grid.get_board_pixel_size()
	custom_minimum_size = pixel_size
	size = pixel_size


func _draw() -> void:
	if _grid == null:
		return

	var board_size: Vector2 = _grid.get_board_pixel_size()

	# 1. LCD playfield background (briefly inverted/tinted on collision or eat feedback)
	var bg_color: Color = GameConfig.color_lcd_bg
	if _flash_timer > 0.0:
		if _flash_is_collision and int(_flash_timer * 25.0) % 2 == 0:
			bg_color = GameConfig.color_lcd_dark
		elif not _flash_is_collision:
			bg_color = GameConfig.color_lcd_light
	draw_rect(Rect2(Vector2.ZERO, board_size), bg_color, true)

	# 2. Subtle pixel grid lines
	if show_grid_lines:
		_draw_grid_lines(board_size)

	# 3. Food pixel sprite (classic monochrome diamond/cross pattern)
	if _grid.is_within_bounds(_food_cell):
		_draw_food(_food_cell)

	# 4. Snake body and head segments
	_draw_snake()

	# 5. Crisp inner LCD playfield border
	draw_rect(Rect2(Vector2.ZERO, board_size), GameConfig.color_lcd_deep, false, 2.0)


func _draw_grid_lines(board_size: Vector2) -> void:
	var cs: int = _grid.cell_size
	for col in range(1, _grid.columns):
		var x: float = float(col * cs)
		draw_line(Vector2(x, 0.0), Vector2(x, board_size.y), GameConfig.color_lcd_light, 1.0)
	for row in range(1, _grid.rows):
		var y: float = float(row * cs)
		draw_line(Vector2(0.0, y), Vector2(board_size.x, y), GameConfig.color_lcd_light, 1.0)


func _draw_food(cell: Vector2i) -> void:
	var origin: Vector2 = _grid.grid_to_local(cell)
	var cs: float = float(_grid.cell_size)
	var px: float = floor(cs / 6.0) # 3px sub-pixel unit for 18px cells

	# Classic 3310-style 4-dot diamond food pattern (direct draws, zero per-frame allocation)
	draw_rect(Rect2(origin + Vector2(px * 2.0, px * 1.0), Vector2(px * 2.0, px * 1.0)), GameConfig.color_lcd_deep, true)
	draw_rect(Rect2(origin + Vector2(px * 2.0, px * 4.0), Vector2(px * 2.0, px * 1.0)), GameConfig.color_lcd_deep, true)
	draw_rect(Rect2(origin + Vector2(px * 1.0, px * 2.0), Vector2(px * 1.0, px * 2.0)), GameConfig.color_lcd_deep, true)
	draw_rect(Rect2(origin + Vector2(px * 4.0, px * 2.0), Vector2(px * 1.0, px * 2.0)), GameConfig.color_lcd_deep, true)

	# Subtle 2-state retro center pixel pulse
	var center_color: Color = GameConfig.color_lcd_deep if _pulse_on else GameConfig.color_lcd_dark
	draw_rect(Rect2(origin + Vector2(px * 2.5, px * 2.5), Vector2(px, px)), center_color, true)


func _draw_snake() -> void:
	var cs: float = float(_grid.cell_size)
	var pad: float = 2.0

	for i in range(_snake_cells.size()):
		var cell: Vector2i = _snake_cells[i]
		if not _grid.is_within_bounds(cell):
			continue

		var origin: Vector2 = _grid.grid_to_local(cell)
		var is_head: bool = (i == 0)
		var is_tail: bool = (i == _snake_cells.size() - 1 and _snake_cells.size() > 1)

		if is_head:
			_draw_snake_head(origin, cs)
		elif is_tail:
			var tail_pad: float = pad + 2.0
			draw_rect(
				Rect2(origin + Vector2(tail_pad, tail_pad), Vector2(cs - tail_pad * 2.0, cs - tail_pad * 2.0)),
				GameConfig.color_lcd_deep,
				true
			)
		else:
			# Classic segmented LCD body block with subtle inner highlight
			draw_rect(
				Rect2(origin + Vector2(pad, pad), Vector2(cs - pad * 2.0, cs - pad * 2.0)),
				GameConfig.color_lcd_deep,
				true
			)
			var inner_pad: float = pad + 3.0
			draw_rect(
				Rect2(origin + Vector2(inner_pad, inner_pad), Vector2(cs - inner_pad * 2.0, cs - inner_pad * 2.0)),
				GameConfig.color_lcd_dark,
				false,
				1.0
			)


func _draw_snake_head(origin: Vector2, cs: float) -> void:
	var pad: float = 1.0
	draw_rect(
		Rect2(origin + Vector2(pad, pad), Vector2(cs - pad * 2.0, cs - pad * 2.0)),
		GameConfig.color_lcd_deep,
		true
	)

	# Draw two crisp LCD eyes oriented in the current movement direction
	var eye_size := Vector2(3.0, 3.0)
	var eye_a: Vector2
	var eye_b: Vector2

	if _snake_direction == Vector2i.RIGHT:
		eye_a = Vector2(cs - 6.0, 4.0)
		eye_b = Vector2(cs - 6.0, cs - 7.0)
	elif _snake_direction == Vector2i.LEFT:
		eye_a = Vector2(3.0, 4.0)
		eye_b = Vector2(3.0, cs - 7.0)
	elif _snake_direction == Vector2i.UP:
		eye_a = Vector2(4.0, 3.0)
		eye_b = Vector2(cs - 7.0, 3.0)
	else: # DOWN
		eye_a = Vector2(4.0, cs - 6.0)
		eye_b = Vector2(cs - 7.0, cs - 6.0)

	draw_rect(Rect2(origin + eye_a, eye_size), GameConfig.color_lcd_bg, true)
	draw_rect(Rect2(origin + eye_b, eye_size), GameConfig.color_lcd_bg, true)
