class_name GridSystem
extends RefCounted
## Manages discrete 2D grid coordinates, bounds validation, wraparound, and pixel mapping.

var columns: int
var rows: int
var cell_size: int


func _init(
	p_columns: int = GameConfig.GRID_COLUMNS,
	p_rows: int = GameConfig.GRID_ROWS,
	p_cell_size: int = GameConfig.CELL_SIZE
) -> void:
	columns = maxi(1, p_columns)
	rows = maxi(1, p_rows)
	cell_size = maxi(1, p_cell_size)


func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < columns and cell.y >= 0 and cell.y < rows


func wrap_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(posmod(cell.x, columns), posmod(cell.y, rows))


func grid_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size, cell.y * cell_size)


func grid_to_center(cell: Vector2i) -> Vector2:
	var half: float = float(cell_size) * 0.5
	return grid_to_local(cell) + Vector2(half, half)


func get_board_pixel_size() -> Vector2:
	return Vector2(columns * cell_size, rows * cell_size)


func get_total_cells() -> int:
	return columns * rows
