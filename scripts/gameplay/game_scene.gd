class_name GameScene
extends Control
## Main game scene: LCD board, HUD, Ready/Pause/Game Over overlays, touch D-pad, and swipe input.

signal menu_requested

@onready var board_stage: Control = %BoardStage
@onready var board_renderer: BoardRenderer = %BoardRenderer
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var difficulty_label: Label = %DifficultyLabel

@onready var ready_overlay: Control = %ReadyOverlay
@onready var pause_overlay: Control = %PauseOverlay
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_title: Label = %GameOverTitle
@onready var game_over_stats: Label = %GameOverStats
@onready var new_record_label: Label = %NewRecordLabel

@onready var resume_button: Button = %ResumeButton
@onready var pause_restart_button: Button = %PauseRestartButton
@onready var pause_menu_button: Button = %PauseMenuButton
@onready var play_again_button: Button = %PlayAgainButton
@onready var game_over_menu_button: Button = %GameOverMenuButton

@onready var pause_button: Button = %PauseButton
@onready var restart_button: Button = %RestartButton
@onready var circular_dpad: CircularDpad = %CircularDpad

var grid: GridSystem
var session: SnakeGameSession
var score_manager: ScoreManager
var audio_manager: AudioManager
var move_interval: float = GameConfig.DEFAULT_MOVE_INTERVAL

var _swipe_detector: SwipeDetector = SwipeDetector.new()
var _move_accumulator: float = 0.0
var _achieved_new_record: bool = false
var _paused_from_ready: bool = false
var _icon_pause: Texture2D
var _icon_play: Texture2D
var _icon_restart: Texture2D


func _ready() -> void:
	grid = GridSystem.new(
		GameConfig.GRID_COLUMNS,
		GameConfig.GRID_ROWS,
		GameConfig.CELL_SIZE
	)
	if score_manager == null:
		score_manager = ScoreManager.new()
	session = SnakeGameSession.new(grid, score_manager.wrap_walls)
	board_renderer.set_grid(grid)

	_connect_controls()
	_style_keypad()
	board_stage.resized.connect(_on_board_stage_resized)
	start_new_game(false)


static func compute_adaptive_grid_params(stage_size: Vector2) -> Vector3i:
	# Returns Vector3i(columns, rows, cell_size) that fills BoardStage cleanly with crisp integer cells.
	var cols: int = GameConfig.GRID_COLUMNS
	if stage_size.x < 100.0 or stage_size.y < 100.0:
		return Vector3i(cols, GameConfig.GRID_ROWS, GameConfig.CELL_SIZE)
	var cell_px: int = clampi(int(floor(stage_size.x / float(cols))), 16, 28)
	var rows: int = clampi(int(floor(stage_size.y / float(cell_px))), 16, 32)
	return Vector3i(cols, rows, cell_px)


func _on_board_stage_resized() -> void:
	if session != null and session.state == SnakeGameSession.State.READY:
		_adapt_grid_to_stage(true)


func _adapt_grid_to_stage(reset_session: bool = false) -> void:
	if board_stage == null or grid == null:
		return
	var params: Vector3i = compute_adaptive_grid_params(board_stage.size)
	if grid.columns == params.x and grid.rows == params.y and grid.cell_size == params.z:
		return
	grid = GridSystem.new(params.x, params.y, params.z)
	session.grid = grid
	board_renderer.set_grid(grid)
	if reset_session:
		session.reset(score_manager.wrap_walls, false)
	_sync_view()


func configure(p_score_manager: ScoreManager, p_audio_manager: AudioManager = null) -> void:
	score_manager = p_score_manager
	audio_manager = p_audio_manager
	move_interval = score_manager.get_move_interval()


func start_new_game(start_immediately: bool = false) -> void:
	if score_manager == null or session == null:
		return
	_adapt_grid_to_stage(false)
	_move_accumulator = 0.0
	_achieved_new_record = false
	_paused_from_ready = false
	score_manager.reset_score()
	move_interval = score_manager.get_move_interval()
	session.reset(score_manager.wrap_walls, start_immediately)
	_sync_view()


func restart_game() -> void:
	start_new_game(false)


func toggle_pause() -> void:
	if session == null:
		return
	if session.state == SnakeGameSession.State.PLAYING or session.state == SnakeGameSession.State.READY:
		_paused_from_ready = (session.state == SnakeGameSession.State.READY)
		session.state = SnakeGameSession.State.PAUSED
		_sync_view()
		if resume_button != null and is_visible_in_tree():
			resume_button.grab_focus()
	elif session.state == SnakeGameSession.State.PAUSED:
		session.state = SnakeGameSession.State.READY if _paused_from_ready else SnakeGameSession.State.PLAYING
		_paused_from_ready = false
		_sync_view()


func refresh_theme() -> void:
	_style_keypad()
	var bezel: ColorRect = get_node_or_null("OuterBezel") as ColorRect
	if bezel != null:
		bezel.color = GameConfig.color_lcd_dark
	var divider: ColorRect = get_node_or_null("SafeMargin/MainColumn/LcdFrame/LcdPadding/LcdLayout/HudDivider") as ColorRect
	if divider != null:
		divider.color = GameConfig.color_lcd_deep
	if board_renderer != null:
		board_renderer.queue_redraw()
	if circular_dpad != null:
		circular_dpad.queue_redraw()
	_sync_view()


func set_difficulty(new_difficulty: GameConfig.Difficulty) -> void:
	if score_manager == null:
		return
	score_manager.set_difficulty(new_difficulty)
	move_interval = score_manager.get_move_interval()
	_sync_view()


func request_direction(new_direction: Vector2i) -> bool:
	if session == null:
		return false
	if session.state == SnakeGameSession.State.READY:
		session.state = SnakeGameSession.State.PLAYING
		session.request_direction(new_direction)
		_sync_view()
		return true
	return session.request_direction(new_direction)


func _notification(what: int) -> void:
	# Auto-pause when the Android app loses focus or enters background.
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if session != null and session.state == SnakeGameSession.State.PLAYING:
			toggle_pause()


func _input(event: InputEvent) -> void:
	if not visible or session == null:
		return
	if session.state == SnakeGameSession.State.PAUSED or session.state == SnakeGameSession.State.GAME_OVER:
		_swipe_detector.end_drag()
		return
	_handle_swipe_input(event)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or session == null:
		return

	if event.is_action_pressed("pause_game"):
		if session.state != SnakeGameSession.State.GAME_OVER:
			toggle_pause()
			get_viewport().set_input_as_handled()
		return

	if session.state == SnakeGameSession.State.GAME_OVER:
		if event.is_action_pressed("ui_accept"):
			restart_game()
			get_viewport().set_input_as_handled()
		return

	if session.state == SnakeGameSession.State.PAUSED:
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
	if not visible or session == null or session.state != SnakeGameSession.State.PLAYING:
		return

	# Cap delta so tab-switching or frame hitches never burst multiple ticks at once.
	_move_accumulator += minf(delta, move_interval * 2.0)
	while _move_accumulator >= move_interval:
		_move_accumulator -= move_interval
		var result: SnakeGameSession.TickResult = session.tick()
		if result == SnakeGameSession.TickResult.ATE_FOOD:
			if score_manager.add_points():
				_achieved_new_record = true
			board_renderer.trigger_eat_flash()
			if audio_manager != null:
				audio_manager.play_eat()
		elif result == SnakeGameSession.TickResult.BOARD_CLEARED:
			if score_manager.add_points():
				_achieved_new_record = true
			board_renderer.trigger_eat_flash()
			if audio_manager != null:
				audio_manager.play_win()
		elif result == SnakeGameSession.TickResult.GAME_OVER_WALL or result == SnakeGameSession.TickResult.GAME_OVER_SELF:
			board_renderer.trigger_collision_flash()
			if audio_manager != null:
				audio_manager.play_game_over()
		_sync_view(result)
		if session.state != SnakeGameSession.State.PLAYING:
			if play_again_button != null and is_visible_in_tree():
				play_again_button.grab_focus()
			break


func _is_point_on_board(pos: Vector2) -> bool:
	return board_stage != null and board_stage.get_global_rect().has_point(pos)


func _handle_swipe_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.index != 0:
			return
		if event.pressed:
			if _is_point_on_board(event.position):
				_swipe_detector.begin_drag(event.position)
		else:
			_swipe_detector.end_drag()
	elif event is InputEventScreenDrag:
		if event.index != 0:
			return
		var dir: Vector2i = _swipe_detector.update_drag(event.position)
		if dir != Vector2i.ZERO:
			request_direction(dir)
	elif not OS.has_feature("android"):
		# Desktop mouse-drag fallback (skipped on Android to avoid duplicate emulate_mouse_from_touch events).
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_point_on_board(event.position):
					_swipe_detector.begin_drag(event.position)
			else:
				_swipe_detector.end_drag()
		elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			var dir: Vector2i = _swipe_detector.update_drag(event.position)
			if dir != Vector2i.ZERO:
				request_direction(dir)


func _connect_controls() -> void:
	circular_dpad.direction_changed.connect(request_direction)

	pause_button.pressed.connect(toggle_pause)
	restart_button.pressed.connect(restart_game)

	resume_button.pressed.connect(toggle_pause)
	pause_restart_button.pressed.connect(restart_game)
	pause_menu_button.pressed.connect(func() -> void: menu_requested.emit())

	play_again_button.pressed.connect(restart_game)
	game_over_menu_button.pressed.connect(func() -> void: menu_requested.emit())


func _style_keypad() -> void:
	_icon_pause = LcdTheme.make_pause_icon()
	_icon_play = LcdTheme.make_play_icon()
	_icon_restart = LcdTheme.make_restart_icon()

	# Match Pause & Restart icon buttons to the dark-green handheld deck for a cohesive controller look.
	LcdTheme.apply_pixel_button(pause_button, LcdTheme.ButtonVariant.HANDHELD_DARK)
	LcdTheme.apply_pixel_button(restart_button, LcdTheme.ButtonVariant.HANDHELD_DARK)
	pause_button.icon = _icon_pause
	restart_button.icon = _icon_restart

	LcdTheme.apply_pixel_button(resume_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(pause_restart_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(pause_menu_button, LcdTheme.ButtonVariant.LCD_SECONDARY)
	LcdTheme.apply_pixel_button(play_again_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(game_over_menu_button, LcdTheme.ButtonVariant.LCD_SECONDARY)


func _sync_view(last_result: SnakeGameSession.TickResult = SnakeGameSession.TickResult.NONE) -> void:
	if session == null or score_manager == null or board_renderer == null:
		return

	board_renderer.set_snake_cells(session.snake.segments, session.snake.direction)
	board_renderer.set_food_cell(session.food_cell)

	score_label.text = "SCR %04d" % score_manager.current_score
	high_score_label.text = "HI %04d" % score_manager.high_score
	difficulty_label.text = GameConfig.get_difficulty_name(score_manager.difficulty)
	if circular_dpad != null:
		circular_dpad.set_classic_style(score_manager.classic_dpad)

	ready_overlay.visible = (session.state == SnakeGameSession.State.READY)
	pause_overlay.visible = (session.state == SnakeGameSession.State.PAUSED)
	game_over_overlay.visible = (session.state == SnakeGameSession.State.GAME_OVER)
	pause_button.icon = _icon_play if session.state == SnakeGameSession.State.PAUSED else _icon_pause

	if session.state == SnakeGameSession.State.GAME_OVER:
		game_over_title.text = "BOARD CLEARED!" if last_result == SnakeGameSession.TickResult.BOARD_CLEARED else "GAME OVER"
		game_over_stats.text = "SCORE: %04d\nBEST:  %04d" % [score_manager.current_score, score_manager.high_score]
		new_record_label.visible = _achieved_new_record
