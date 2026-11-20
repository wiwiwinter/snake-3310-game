class_name MainMenu
extends Control
## Main Menu screen with Play, High Scores, and Settings actions.

signal play_requested
signal high_scores_requested
signal settings_requested

@onready var best_label: Label = %BestLabel
@onready var play_button: Button = %PlayButton
@onready var high_scores_button: Button = %HighScoresButton
@onready var settings_button: Button = %SettingsButton


func _ready() -> void:
	play_button.pressed.connect(func() -> void: play_requested.emit())
	high_scores_button.pressed.connect(func() -> void: high_scores_requested.emit())
	settings_button.pressed.connect(func() -> void: settings_requested.emit())

	LcdTheme.apply_pixel_button(play_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(high_scores_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(settings_button, LcdTheme.ButtonVariant.LCD_PRIMARY)


func refresh(score_manager: ScoreManager) -> void:
	if score_manager != null and best_label != null:
		best_label.text = "BEST SCORE: %04d" % score_manager.high_score
	if play_button != null and is_visible_in_tree():
		play_button.grab_focus()
