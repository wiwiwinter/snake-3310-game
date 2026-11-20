class_name SplashScreen
extends Control
## Brief retro LCD boot screen that advances automatically or on tap/key press.

signal finished

const SPLASH_DURATION: float = 1.2
var _elapsed: float = 0.0
var _done: bool = false


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
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
