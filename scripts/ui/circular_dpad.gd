class_name CircularDpad
extends Control
## Unified monochrome circular D-pad supporting tap and continuous 360-degree thumb rolling.

signal direction_changed(direction: Vector2i)

const DEADZONE_RATIO: float = 0.18

var active_direction: Vector2i = Vector2i.ZERO
var _touch_index: int = -1
var _mouse_held: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_from_local_pos(event.position)
			accept_event()
		elif not event.pressed and event.index == _touch_index:
			_release()
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_from_local_pos(event.position)
		accept_event()
	elif not OS.has_feature("android"):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_held = true
				_update_from_local_pos(event.position)
			else:
				_mouse_held = false
				_release()
			accept_event()
		elif event is InputEventMouseMotion and _mouse_held:
			_update_from_local_pos(event.position)
			accept_event()


func _update_from_local_pos(local_pos: Vector2) -> void:
	var new_dir: Vector2i = compute_direction(local_pos, size)
	if new_dir == Vector2i.ZERO:
		if active_direction != Vector2i.ZERO:
			active_direction = Vector2i.ZERO
			queue_redraw()
		return

	if new_dir != active_direction:
		active_direction = new_dir
		direction_changed.emit(active_direction)
		queue_redraw()


func _release() -> void:
	_touch_index = -1
	_mouse_held = false
	if active_direction != Vector2i.ZERO:
		active_direction = Vector2i.ZERO
		queue_redraw()


static func compute_direction(local_pos: Vector2, control_size: Vector2) -> Vector2i:
	var center: Vector2 = control_size * 0.5
	var radius: float = minf(control_size.x, control_size.y) * 0.5
	var offset: Vector2 = local_pos - center
	if offset.length() < radius * DEADZONE_RATIO:
		return Vector2i.ZERO
	if absf(offset.x) >= absf(offset.y):
		return Vector2i.RIGHT if offset.x > 0.0 else Vector2i.LEFT
	return Vector2i.DOWN if offset.y > 0.0 else Vector2i.UP


func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.5 - 4.0
	if radius <= 8.0:
		return

	# 3D bottom drop shadow and outer deep-green ring
	draw_circle(center + Vector2(0, 4.0), radius, GameConfig.COLOR_LCD_DEEP)
	draw_circle(center, radius, GameConfig.COLOR_LCD_DEEP)
	draw_circle(center, radius - 3.0, GameConfig.COLOR_LCD_DARK)

	# Subtle top rim specular arc
	draw_arc(center, radius - 4.5, PI * 1.12, PI * 1.88, 24, GameConfig.COLOR_LCD_LIGHT, 2.0)

	# Highlight active directional wedge when held/rolled
	if active_direction != Vector2i.ZERO:
		_draw_active_wedge(center, radius - 5.0, active_direction)

	# Subtle diagonal quadrant dividers
	var diag: float = (radius - 6.0) * 0.7071
	draw_line(center + Vector2(-diag, -diag), center + Vector2(diag, diag), GameConfig.COLOR_LCD_DEEP, 2.0)
	draw_line(center + Vector2(diag, -diag), center + Vector2(-diag, diag), GameConfig.COLOR_LCD_DEEP, 2.0)

	# Four directional arrows
	var arrow_dist: float = radius * 0.62
	var arrow_r: float = radius * 0.16
	_draw_arrow(center + Vector2(0, -arrow_dist), Vector2i.UP, arrow_r)
	_draw_arrow(center + Vector2(0, arrow_dist), Vector2i.DOWN, arrow_r)
	_draw_arrow(center + Vector2(-arrow_dist, 0), Vector2i.LEFT, arrow_r)
	_draw_arrow(center + Vector2(arrow_dist, 0), Vector2i.RIGHT, arrow_r)

	# Center recessed pivot dimple
	var pivot_r: float = radius * 0.22
	draw_circle(center, pivot_r, GameConfig.COLOR_LCD_DEEP)
	draw_circle(center, pivot_r - 3.0, GameConfig.COLOR_LCD_DARK)


func _draw_active_wedge(center: Vector2, r: float, dir: Vector2i) -> void:
	var base_angle: float = 0.0
	if dir == Vector2i.RIGHT:
		base_angle = 0.0
	elif dir == Vector2i.DOWN:
		base_angle = PI * 0.5
	elif dir == Vector2i.LEFT:
		base_angle = PI
	else: # UP
		base_angle = -PI * 0.5

	var pts := PackedVector2Array([center])
	var steps: int = 12
	var start_a: float = base_angle - PI * 0.25
	var end_a: float = base_angle + PI * 0.25
	for i in range(steps + 1):
		var a: float = lerpf(start_a, end_a, float(i) / float(steps))
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, GameConfig.COLOR_LCD_BG)


func _draw_arrow(pos: Vector2, dir: Vector2i, r: float) -> void:
	var ink: Color = GameConfig.COLOR_LCD_DEEP if active_direction == dir else GameConfig.COLOR_LCD_BG
	var pts: PackedVector2Array
	if dir == Vector2i.UP:
		pts = PackedVector2Array([pos + Vector2(0, -r), pos + Vector2(-r, r * 0.7), pos + Vector2(r, r * 0.7)])
	elif dir == Vector2i.DOWN:
		pts = PackedVector2Array([pos + Vector2(0, r), pos + Vector2(-r, -r * 0.7), pos + Vector2(r, -r * 0.7)])
	elif dir == Vector2i.LEFT:
		pts = PackedVector2Array([pos + Vector2(-r, 0), pos + Vector2(r * 0.7, -r), pos + Vector2(r * 0.7, r)])
	else:
		pts = PackedVector2Array([pos + Vector2(r, 0), pos + Vector2(-r * 0.7, -r), pos + Vector2(-r * 0.7, r)])
	draw_colored_polygon(pts, ink)
