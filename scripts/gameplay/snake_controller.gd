class_name SnakeController
extends RefCounted
## Manages snake segment positions, cardinal direction, and 2-step turn input buffering.

const VALID_DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]

var segments: Array[Vector2i] = []
var direction: Vector2i = GameConfig.INITIAL_DIRECTION
var _direction_queue: Array[Vector2i] = []


func _init(
	initial_segments: Array[Vector2i] = GameConfig.INITIAL_SNAKE_CELLS,
	initial_direction: Vector2i = GameConfig.INITIAL_DIRECTION
) -> void:
	reset(initial_segments, initial_direction)


func reset(initial_segments: Array[Vector2i], initial_direction: Vector2i) -> void:
	segments = initial_segments.duplicate()
	direction = initial_direction if initial_direction in VALID_DIRECTIONS else Vector2i.RIGHT
	_direction_queue.clear()


func queue_direction(new_direction: Vector2i) -> bool:
	if new_direction not in VALID_DIRECTIONS:
		return false
	if _direction_queue.size() >= GameConfig.MAX_INPUT_QUEUE_SIZE:
		return false

	# Validate against the last planned direction so rapid 2-step turns cannot cause a 180-degree reversal.
	var reference_dir: Vector2i = _direction_queue.back() if not _direction_queue.is_empty() else direction
	if new_direction == reference_dir or new_direction == -reference_dir:
		return false

	_direction_queue.append(new_direction)
	return true


func get_head() -> Vector2i:
	return segments[0] if not segments.is_empty() else Vector2i.ZERO


func get_next_direction() -> Vector2i:
	return _direction_queue.front() if not _direction_queue.is_empty() else direction


func step(grid: GridSystem, grow: bool = false, wrap_walls: bool = true) -> Vector2i:
	if not _direction_queue.is_empty():
		direction = _direction_queue.pop_front()

	var next_head: Vector2i = get_head() + direction
	if wrap_walls and grid != null:
		next_head = grid.wrap_cell(next_head)

	segments.push_front(next_head)
	if not grow and segments.size() > 1:
		segments.pop_back()

	return next_head
