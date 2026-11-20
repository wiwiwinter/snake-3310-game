class_name HighScoreScreen
extends Control
## High Score screen showing overall and per-difficulty best scores.

signal back_requested

@onready var overall_label: Label = %OverallLabel
@onready var easy_label: Label = %EasyLabel
@onready var normal_label: Label = %NormalLabel
@onready var hard_label: Label = %HardLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func refresh(score_manager: ScoreManager) -> void:
	if score_manager == null or overall_label == null:
		return
	overall_label.text = "OVERALL BEST: %04d" % score_manager.high_score
	easy_label.text = "EASY:   %04d" % score_manager.get_high_score_for(GameConfig.Difficulty.EASY)
	normal_label.text = "NORMAL: %04d" % score_manager.get_high_score_for(GameConfig.Difficulty.NORMAL)
	hard_label.text = "HARD:   %04d" % score_manager.get_high_score_for(GameConfig.Difficulty.HARD)
	if back_button != null and is_visible_in_tree():
		back_button.grab_focus()
