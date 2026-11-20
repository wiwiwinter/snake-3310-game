class_name GameScene
extends Control
## Main game scene: LCD board, HUD, Ready/Pause/Game Over overlays, touch D-pad, and swipe input.

signal menu_requested

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
@onready var up_button: Button = %UpButton
@onready var down_button: Button = %DownButton
@onready var left_button: Button = %LeftButton
@onready var right_button: Button = %RightButton

var grid: GridSystem
var session: SnakeGameSession
var score_manager: ScoreManager
var audio_manager: AudioManager
var move_interval: float = GameConfig.DEFAULT_MOVE_INTERVAL

var _swipe_detector: SwipeDetector = SwipeDetector.new()
var _move_accumulator: float = 0.0
var _achieved_new_record: bool = false


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
	start_new_game(false)


func configure(p_score_manager: ScoreManager, p_audio_manager: AudioManager = null) -> void:
	score_manager = p_score_manager
	audio_manager = p_audio_manager
	move_interval = score_manager.get_move_interval()


func start_new_game(start_immediately: bool = false) -> void:
	if score_manager == null or session == null:
		return
	_move_accumulator = 0.0
	_achieved_new_record = false
	score_manager.reset_score()
	move_interval = score_manager.get_move_interval()
	session.reset(score_manager.wrap_walls, start_immediately)
	_sync_view()


func restart_game() -> void:
	start_new_game(false)


func toggle_pause() -> void:
	if session == null:
		return
	if session.state == SnakeGameSession.State.PLAYING:
		session.state = SnakeGameSession.State.PAUSED
		_sync_view()
		if resume_button != null and is_visible_in_tree():
			resume_button.grab_focus()
	elif session.state == SnakeGameSession.State.PAUSED:
		session.state = SnakeGameSession.State.PLAYING
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
	# Handle touch/pointer swipes in _input so Control panels/labels cannot swallow drag events.
	_handle_swipe_input(event)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or session == null:
		return

	if event.is_action_pressed("pause_game"):
		if session.state == SnakeGameSession.State.PLAYING or session.state == SnakeGameSession.State.PAUSED:
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


func _handle_swipe_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.index != 0:
			return
		if event.pressed:
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
				_swipe_detector.begin_drag(event.position)
			else:
				_swipe_detector.end_drag()
		elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			var dir: Vector2i = _swipe_detector.update_drag(event.position)
			if dir != Vector2i.ZERO:
				request_direction(dir)


func _connect_controls() -> void:
	up_button.button_down.connect(func() -> void: request_direction(Vector2i.UP))
	down_button.button_down.connect(func() -> void: request_direction(Vector2i.DOWN))
	left_button.button_down.connect(func() -> void: request_direction(Vector2i.LEFT))
	right_button.button_down.connect(func() -> void: request_direction(Vector2i.RIGHT))

	pause_button.pressed.connect(toggle_pause)
	restart_button.pressed.connect(restart_game)

	resume_button.pressed.connect(toggle_pause)
	pause_restart_button.pressed.connect(restart_game)
	pause_menu_button.pressed.connect(func() -> void: menu_requested.emit())

	play_again_button.pressed.connect(restart_game)
	game_over_menu_button.pressed.connect(func() -> void: menu_requested.emit())


func _style_keypad() -> void:
	for btn in [up_button, down_button, left_button, right_button]:
		LcdTheme.apply_pixel_button(btn, LcdTheme.ButtonVariant.CYAN)
	LcdTheme.apply_pixel_button(pause_button, LcdTheme.ButtonVariant.AMBER)
	LcdTheme.apply_pixel_button(restart_button, LcdTheme.ButtonVariant.RED)
	LcdTheme.apply_pixel_button(resume_button, LcdTheme.ButtonVariant.GREEN)
	LcdTheme.apply_pixel_button(pause_restart_button, LcdTheme.ButtonVariant.AMBER)
	LcdTheme.apply_pixel_button(pause_menu_button, LcdTheme.ButtonVariant.RED)
	LcdTheme.apply_pixel_button(play_again_button, LcdTheme.ButtonVariant.GREEN)
	LcdTheme.apply_pixel_button(game_over_menu_button, LcdTheme.ButtonVariant.RED)


func _sync_view(last_result: SnakeGameSession.TickResult = SnakeGameSession.TickResult.NONE) -> void:
	if session == null or score_manager == null or board_renderer == null:
		return

	board_renderer.set_snake_cells(session.snake.segments, session.snake.direction)
	board_renderer.set_food_cell(session.food_cell)

	score_label.text = "SCR %04d" % score_manager.current_score
	high_score_label.text = "HI %04d" % score_manager.high_score
	difficulty_label.text = GameConfig.get_difficulty_name(score_manager.difficulty)

	ready_overlay.visible = (session.state == SnakeGameSession.State.READY)
	pause_overlay.visible = (session.state == SnakeGameSession.State.PAUSED)
	game_over_overlay.visible = (session.state == SnakeGameSession.State.GAME_OVER)
	pause_button.text = "RESUME" if session.state == SnakeGameSession.State.PAUSED else "PAUSE"

	if session.state == SnakeGameSession.State.GAME_OVER:
		game_over_title.text = "BOARD CLEARED!" if last_result == SnakeGameSession.TickResult.BOARD_CLEARED else "GAME OVER"
		game_over_stats.text = "SCORE: %04d\nBEST:  %04d" % [score_manager.current_score, score_manager.high_score]
		new_record_label.visible = _achieved_new_record
