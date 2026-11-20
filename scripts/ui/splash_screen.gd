class_name SplashScreen
extends Control
## Eye-catching retro LCD boot screen with animated progress bar and tap/key skip.

signal finished

const SPLASH_DURATION: float = 1.6

@onready var progress_fill: ColorRect = %ProgressFill
@onready var hint_label: Label = %HintLabel

var _elapsed: float = 0.0
var _done: bool = false


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	var ratio: float = clampf(_elapsed / SPLASH_DURATION, 0.0, 1.0)
	if progress_fill != null:
		progress_fill.anchor_right = ratio
	if hint_label != null:
		hint_label.modulate.a = 1.0 if int(_elapsed * 3.5) % 2 == 0 else 0.35
	if _elapsed >= SPLASH_DURATION:
		_complete()


func _unhandled_input(event: InputEvent) -> void:
	if _done:
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
