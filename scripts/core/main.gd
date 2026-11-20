class_name Main
extends Control
## Root screen router managing Splash, Main Menu, Game, Settings, and High Scores.

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
var current_screen: Screen = Screen.SPLASH


func _ready() -> void:
	theme = LcdTheme.create_theme()
	score_manager = ScoreManager.new()
	game_scene.configure(score_manager)

	splash_screen.finished.connect(show_main_menu)
	main_menu.play_requested.connect(show_game)
	main_menu.high_scores_requested.connect(show_high_scores)
	main_menu.settings_requested.connect(show_settings)
	settings_screen.back_requested.connect(show_main_menu)
	high_score_screen.back_requested.connect(show_main_menu)
	game_scene.menu_requested.connect(show_main_menu)

	show_splash()
	print("Snake 3310 initialized (Phase 6: UI/UX & Navigation).")


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


func _switch_screen(target: Screen) -> void:
	current_screen = target
	splash_screen.visible = (target == Screen.SPLASH)
	main_menu.visible = (target == Screen.MAIN_MENU)
	game_scene.visible = (target == Screen.GAME)
	settings_screen.visible = (target == Screen.SETTINGS)
	high_score_screen.visible = (target == Screen.HIGH_SCORES)
