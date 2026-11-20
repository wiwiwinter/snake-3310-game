class_name SwipeDetector
extends RefCounted
## Converts touch/pointer drags into cardinal directions once movement exceeds a deadzone.

const DEFAULT_THRESHOLD_PX: float = 28.0

var threshold_px: float
var _tracking: bool = false
var _start_pos: Vector2 = Vector2.ZERO
var _triggered_this_drag: bool = false


func _init(p_threshold_px: float = DEFAULT_THRESHOLD_PX) -> void:
	threshold_px = maxf(8.0, p_threshold_px)


func begin_drag(pos: Vector2) -> void:
	_tracking = true
	_start_pos = pos
	_triggered_this_drag = false


func end_drag() -> void:
	_tracking = false
	_triggered_this_drag = false


func update_drag(pos: Vector2) -> Vector2i:
	if not _tracking or _triggered_this_drag:
		return Vector2i.ZERO

	var delta: Vector2 = pos - _start_pos
	if delta.length() < threshold_px:
		return Vector2i.ZERO

	_triggered_this_drag = true
	if absf(delta.x) >= absf(delta.y):
		return Vector2i.RIGHT if delta.x > 0.0 else Vector2i.LEFT
	return Vector2i.DOWN if delta.y > 0.0 else Vector2i.UP
