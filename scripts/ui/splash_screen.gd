class_name SplashScreen
extends Control
## Eye-catching retro LCD boot screen with animated progress bar and tap/key skip.

signal finished

const SPLASH_DURATION: float = 1.6

@onready var progress_fill: ColorRect = %ProgressFill
@onready var hint_label: Label = %HintLabel

var _elapsed: float = 0.0
var _done: bool = false


func refresh_theme() -> void:
	var bezel: ColorRect = get_node_or_null("OuterBezel") as ColorRect
	if bezel != null:
		bezel.color = GameConfig.color_lcd_dark
	var track: ColorRect = get_node_or_null("Margin/LcdFrame/Inner/Box/LoadingTrack") as ColorRect
	if track != null:
		track.color = GameConfig.color_lcd_light
	if progress_fill != null:
		progress_fill.color = GameConfig.color_lcd_deep
	var banner: Control = get_node_or_null("Margin/LcdFrame/Inner/Box/SnakeBanner") as Control
	if banner != null:
		banner.queue_redraw()


func _process(delta: float) -> void:
	if _done or not visible:
		return
	_elapsed += delta
	var ratio: float = clampf(_elapsed / SPLASH_DURATION, 0.0, 1.0)
	if progress_fill != null:
		progress_fill.anchor_right = ratio
	if hint_label != null:
		hint_label.modulate.a = 1.0 if int(_elapsed * 3.5) % 2 == 0 else 0.35
	if _elapsed >= SPLASH_DURATION:
		_complete()


func _input(event: InputEvent) -> void:
	if not visible or _done:
		return
	if event is InputEventScreenTouch and event.pressed:
		_complete()
	elif event is InputEventMouseButton and event.pressed:
		_complete()
	elif event is InputEventKey and event.pressed and not event.echo:
		_complete()


func _complete() -> void:
	if _done:
		return
	_done = true
	finished.emit()
