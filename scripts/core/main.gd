class_name Main
extends Control
## Root screen router managing Splash, Main Menu, Game, Settings, High Scores, and AudioManager.

enum Screen {
	SPLASH,
	MAIN_MENU,
	GAME,
	SETTINGS,
	HIGH_SCORES,
}

@onready var splash_screen: SplashScreen = %SplashScreen
@onready var main_menu: MainMenu = %MainMenu
@onready var game_scene: GameScene = %GameScene
@onready var settings_screen: SettingsScreen = %SettingsScreen
@onready var high_score_screen: HighScoreScreen = %HighScoreScreen

var score_manager: ScoreManager
var audio_manager: AudioManager
var current_screen: Screen = Screen.SPLASH
var _screen_tween: Tween


func _ready() -> void:
	theme = LcdTheme.create_theme()
	score_manager = ScoreManager.new()

	audio_manager = AudioManager.new()
	add_child(audio_manager)
	audio_manager.apply_settings(score_manager.sfx_enabled, score_manager.music_enabled)

	game_scene.configure(score_manager, audio_manager)

	splash_screen.finished.connect(show_main_menu)
	main_menu.play_requested.connect(_on_play_requested)
	main_menu.high_scores_requested.connect(_on_high_scores_requested)
	main_menu.settings_requested.connect(_on_settings_requested)
	settings_screen.back_requested.connect(_on_back_to_menu)
	settings_screen.audio_settings_changed.connect(_on_audio_settings_changed)
	high_score_screen.back_requested.connect(_on_back_to_menu)
	game_scene.menu_requested.connect(_on_back_to_menu)

	show_splash()
	_apply_display_safe_area()
	get_viewport().size_changed.connect(_apply_display_safe_area)
	print("Snake 3310 initialized (Phase 7: Audio & Polish).")


static func compute_top_safe_inset(safe_rect: Rect2i, window_size: Vector2i, viewport_height: float, is_android: bool) -> int:
	var inset_px: float = 0.0
	if window_size.y > 0 and safe_rect.position.y > 0:
		inset_px = float(safe_rect.position.y) * (viewport_height / float(window_size.y))
	if is_android:
		# Ensure punch-hole camera clearance even when Android immersive mode reports 0 safe-area inset.
		inset_px = maxf(inset_px, 42.0)
	return int(ceil(inset_px))


func _apply_display_safe_area() -> void:
	var vp_h: float = get_viewport_rect().size.y
	if vp_h <= 0.0:
		vp_h = 640.0
	var top_inset: int = compute_top_safe_inset(
		DisplayServer.get_display_safe_area(),
		DisplayServer.window_get_size(),
		vp_h,
		OS.has_feature("android")
	)
	if top_inset <= 0:
		return

	var targets: Array[Array] = [
		[game_scene.get_node_or_null("SafeMargin"), 10],
		[main_menu.get_node_or_null("Margin"), 28],
		[splash_screen.get_node_or_null("Margin"), 44],
		[settings_screen.get_node_or_null("Margin"), 36],
		[high_score_screen.get_node_or_null("Margin"), 36],
	]
	for entry in targets:
		var margin: MarginContainer = entry[0] as MarginContainer
		var base_top: int = int(entry[1])
		if margin != null:
			margin.add_theme_constant_override("margin_top", maxi(base_top, top_inset))


func show_splash() -> void:
	_switch_screen(Screen.SPLASH)


func show_main_menu() -> void:
	_switch_screen(Screen.MAIN_MENU)
	main_menu.refresh(score_manager)


func show_game() -> void:
	_switch_screen(Screen.GAME)
	game_scene.start_new_game(false)


func show_settings() -> void:
	_switch_screen(Screen.SETTINGS)
	settings_screen.refresh(score_manager)


func show_high_scores() -> void:
	_switch_screen(Screen.HIGH_SCORES)
	high_score_screen.refresh(score_manager)


func _on_play_requested() -> void:
	audio_manager.play_click()
	show_game()


func _on_high_scores_requested() -> void:
	audio_manager.play_click()
	show_high_scores()


func _on_settings_requested() -> void:
	audio_manager.play_click()
	show_settings()


func _on_back_to_menu() -> void:
	audio_manager.play_click()
	show_main_menu()


func _on_audio_settings_changed() -> void:
	audio_manager.apply_settings(score_manager.sfx_enabled, score_manager.music_enabled)
	audio_manager.play_click()


func _exit_tree() -> void:
	if _screen_tween != null and _screen_tween.is_valid():
		_screen_tween.kill()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		handle_android_back()


func handle_android_back() -> void:
	match current_screen:
		Screen.SPLASH:
			show_main_menu()
		Screen.SETTINGS, Screen.HIGH_SCORES:
			_on_back_to_menu()
		Screen.GAME:
			if game_scene.session != null and (
				game_scene.session.state == SnakeGameSession.State.PLAYING
				or game_scene.session.state == SnakeGameSession.State.PAUSED
			):
				game_scene.toggle_pause()
			else:
				_on_back_to_menu()
		Screen.MAIN_MENU:
			pass


func _switch_screen(target: Screen) -> void:
	current_screen = target
	splash_screen.visible = (target == Screen.SPLASH)
	main_menu.visible = (target == Screen.MAIN_MENU)
	game_scene.visible = (target == Screen.GAME)
	settings_screen.visible = (target == Screen.SETTINGS)
	high_score_screen.visible = (target == Screen.HIGH_SCORES)

	# Subtle 120ms fade-in for crisp retro LCD screen transitions.
	var active_node: Control = _get_screen_node(target)
	if active_node != null and active_node.is_inside_tree():
		if _screen_tween != null and _screen_tween.is_valid():
			_screen_tween.kill()
		active_node.modulate.a = 0.25
		_screen_tween = create_tween()
		_screen_tween.tween_property(active_node, "modulate:a", 1.0, 0.12)


func _get_screen_node(screen: Screen) -> Control:
	match screen:
		Screen.SPLASH:
			return splash_screen
		Screen.MAIN_MENU:
			return main_menu
		Screen.GAME:
			return game_scene
		Screen.SETTINGS:
			return settings_screen
		Screen.HIGH_SCORES:
			return high_score_screen
	return null
