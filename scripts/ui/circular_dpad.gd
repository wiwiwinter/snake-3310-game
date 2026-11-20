class_name CircularDpad
extends Control
## Unified monochrome circular D-pad supporting tap and continuous 360-degree thumb rolling.

signal direction_changed(direction: Vector2i)

const DEADZONE_RATIO: float = 0.18

var active_direction: Vector2i = Vector2i.ZERO
var classic_style: bool = false
var _touch_index: int = -1
var _mouse_held: bool = false


func set_classic_style(enabled: bool) -> void:
	if classic_style != enabled:
		classic_style = enabled
		queue_redraw()


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

	if classic_style:
		_draw_classic_cross(center, radius)
		return

	# 3D bottom drop shadow and outer deep-green ring
	draw_circle(center + Vector2(0, 4.0), radius, GameConfig.color_lcd_deep)
	draw_circle(center, radius, GameConfig.color_lcd_deep)
	draw_circle(center, radius - 3.0, GameConfig.color_lcd_dark)

	# Subtle top rim specular arc
	draw_arc(center, radius - 4.5, PI * 1.12, PI * 1.88, 24, GameConfig.color_lcd_light, 2.0)

	# Highlight active directional wedge when held/rolled
	if active_direction != Vector2i.ZERO:
		_draw_active_wedge(center, radius - 5.0, active_direction)

	# Subtle diagonal quadrant dividers
	var diag: float = (radius - 6.0) * 0.7071
	draw_line(center + Vector2(-diag, -diag), center + Vector2(diag, diag), GameConfig.color_lcd_deep, 2.0)
	draw_line(center + Vector2(diag, -diag), center + Vector2(-diag, diag), GameConfig.color_lcd_deep, 2.0)

	# Four directional arrows
	var arrow_dist: float = radius * 0.62
	var arrow_r: float = radius * 0.16
	_draw_arrow(center + Vector2(0, -arrow_dist), Vector2i.UP, arrow_r)
	_draw_arrow(center + Vector2(0, arrow_dist), Vector2i.DOWN, arrow_r)
	_draw_arrow(center + Vector2(-arrow_dist, 0), Vector2i.LEFT, arrow_r)
	_draw_arrow(center + Vector2(arrow_dist, 0), Vector2i.RIGHT, arrow_r)

	# Center recessed pivot dimple
	var pivot_r: float = radius * 0.22
	draw_circle(center, pivot_r, GameConfig.color_lcd_deep)
	draw_circle(center, pivot_r - 3.0, GameConfig.color_lcd_dark)


func _draw_classic_cross(center: Vector2, radius: float) -> void:
	var arm_w: float = floor(radius * 0.68)
	var half_arm: float = arm_w * 0.5
	var span: float = radius * 1.92
	var half_span: float = span * 0.5

	var v_rect := Rect2(center.x - half_arm, center.y - half_span, arm_w, span)
	var h_rect := Rect2(center.x - half_span, center.y - half_arm, span, arm_w)

	# 3D bottom drop shadow & deep-green outer outline
	draw_rect(Rect2(v_rect.position + Vector2(-3, -3), v_rect.size + Vector2(6, 10)), GameConfig.color_lcd_deep, true)
	draw_rect(Rect2(h_rect.position + Vector2(-3, -3), h_rect.size + Vector2(6, 10)), GameConfig.color_lcd_deep, true)

	# Main dark-green cross body
	draw_rect(v_rect, GameConfig.color_lcd_dark, true)
	draw_rect(h_rect, GameConfig.color_lcd_dark, true)

	# Crisp top highlight strips on horizontal & top arm
	draw_rect(Rect2(v_rect.position + Vector2(2, 2), Vector2(arm_w - 4, 3)), GameConfig.color_lcd_light, true)
	draw_rect(Rect2(h_rect.position + Vector2(2, 2), Vector2(half_span - half_arm - 2, 3)), GameConfig.color_lcd_light, true)
	draw_rect(Rect2(Vector2(center.x + half_arm, h_rect.position.y + 2), Vector2(half_span - half_arm - 2, 3)), GameConfig.color_lcd_light, true)

	# Highlight active pressed/rolled arm
	if active_direction == Vector2i.UP:
		draw_rect(Rect2(center.x - half_arm + 2, center.y - half_span + 2, arm_w - 4, half_span - half_arm - 2), GameConfig.color_lcd_bg, true)
	elif active_direction == Vector2i.DOWN:
		draw_rect(Rect2(center.x - half_arm + 2, center.y + half_arm, arm_w - 4, half_span - half_arm - 2), GameConfig.color_lcd_bg, true)
	elif active_direction == Vector2i.LEFT:
		draw_rect(Rect2(center.x - half_span + 2, center.y - half_arm + 2, half_span - half_arm - 2, arm_w - 4), GameConfig.color_lcd_bg, true)
	elif active_direction == Vector2i.RIGHT:
		draw_rect(Rect2(center.x + half_arm, center.y - half_arm + 2, half_span - half_arm - 2, arm_w - 4), GameConfig.color_lcd_bg, true)

	# Directional arrows & center recessed dimple
	var arrow_dist: float = radius * 0.64
	var arrow_r: float = radius * 0.15
	_draw_arrow(center + Vector2(0, -arrow_dist), Vector2i.UP, arrow_r)
	_draw_arrow(center + Vector2(0, arrow_dist), Vector2i.DOWN, arrow_r)
	_draw_arrow(center + Vector2(-arrow_dist, 0), Vector2i.LEFT, arrow_r)
	_draw_arrow(center + Vector2(arrow_dist, 0), Vector2i.RIGHT, arrow_r)

	var pivot_r: float = radius * 0.18
	draw_circle(center, pivot_r, GameConfig.color_lcd_deep)
	draw_circle(center, pivot_r - 2.5, GameConfig.color_lcd_dark)


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
	draw_colored_polygon(pts, GameConfig.color_lcd_bg)


func _draw_arrow(pos: Vector2, dir: Vector2i, r: float) -> void:
	var ink: Color = GameConfig.color_lcd_deep if active_direction == dir else GameConfig.color_lcd_bg
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
