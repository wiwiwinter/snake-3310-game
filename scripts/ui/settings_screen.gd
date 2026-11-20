class_name SettingsScreen
extends Control
## Settings screen for difficulty, wall behavior, SFX, and music toggles.

signal back_requested
signal audio_settings_changed

@onready var difficulty_button: Button = %DifficultyButton
@onready var walls_button: Button = %WallsButton
@onready var dpad_button: Button = %DpadButton
@onready var sfx_button: Button = %SfxButton
@onready var music_button: Button = %MusicButton
@onready var back_button: Button = %BackButton

var _score_manager: ScoreManager


func _ready() -> void:
	difficulty_button.pressed.connect(_on_cycle_difficulty)
	walls_button.pressed.connect(_on_toggle_walls)
	dpad_button.pressed.connect(_on_toggle_dpad)
	sfx_button.pressed.connect(_on_toggle_sfx)
	music_button.pressed.connect(_on_toggle_music)
	back_button.pressed.connect(func() -> void: back_requested.emit())

	LcdTheme.apply_pixel_button(difficulty_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(walls_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(dpad_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(sfx_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(music_button, LcdTheme.ButtonVariant.LCD_PRIMARY)
	LcdTheme.apply_pixel_button(back_button, LcdTheme.ButtonVariant.LCD_SECONDARY)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func refresh(score_manager: ScoreManager) -> void:
	_score_manager = score_manager
	_update_labels()
	if difficulty_button != null and is_visible_in_tree():
		difficulty_button.grab_focus()


func _on_cycle_difficulty() -> void:
	if _score_manager == null:
		return
	var next_diff: int = (int(_score_manager.difficulty) + 1) % 3
	_score_manager.set_difficulty(next_diff as GameConfig.Difficulty)
	_update_labels()


func _on_toggle_walls() -> void:
	if _score_manager == null:
		return
	_score_manager.set_wrap_walls(not _score_manager.wrap_walls)
	_update_labels()


func _on_toggle_dpad() -> void:
	if _score_manager == null:
		return
	_score_manager.set_classic_dpad(not _score_manager.classic_dpad)
	_update_labels()


func _on_toggle_sfx() -> void:
	if _score_manager == null:
		return
	_score_manager.set_sfx_enabled(not _score_manager.sfx_enabled)
	_update_labels()
	audio_settings_changed.emit()


func _on_toggle_music() -> void:
	if _score_manager == null:
		return
	_score_manager.set_music_enabled(not _score_manager.music_enabled)
	_update_labels()
	audio_settings_changed.emit()


func _update_labels() -> void:
	if _score_manager == null or difficulty_button == null:
		return
	difficulty_button.text = "SPEED: %s" % GameConfig.get_difficulty_name(_score_manager.difficulty)
	walls_button.text = "WALLS: %s" % ("WRAP" if _score_manager.wrap_walls else "SOLID")
	dpad_button.text = "D-PAD: %s" % ("CLASSIC" if _score_manager.classic_dpad else "CIRCLE")
	sfx_button.text = "SFX: %s" % ("ON" if _score_manager.sfx_enabled else "OFF")
	music_button.text = "MUSIC: %s" % ("ON" if _score_manager.music_enabled else "OFF")
