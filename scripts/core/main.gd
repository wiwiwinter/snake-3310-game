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
	print("Snake 3310 initialized (Phase 7: Audio & Polish).")


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
