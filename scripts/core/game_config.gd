class_name GameConfig
extends RefCounted
## Shared visual palette and grid configuration constants for Snake 3310.

# Classic monochrome green LCD palette
const COLOR_LCD_BG := Color("#9BBC0F")       # Primary LCD background
const COLOR_LCD_LIGHT := Color("#8BAC0F")    # Subtle grid lines / secondary background
const COLOR_LCD_DARK := Color("#306230")     # Outer framing / muted accents
const COLOR_LCD_DEEP := Color("#0F380F")     # Active LCD pixels (snake, food, borders, text)

# Grid dimensions (16x20 at 18px = 288x360 px playable LCD area)
const GRID_COLUMNS: int = 16
const GRID_ROWS: int = 20
const CELL_SIZE: int = 18

# Default initial placement for Phase 2 rendering & new game resets
const INITIAL_SNAKE_CELLS: Array[Vector2i] = [
	Vector2i(6, 10),
	Vector2i(5, 10),
	Vector2i(4, 10),
	Vector2i(3, 10),
]
const INITIAL_DIRECTION := Vector2i.RIGHT
const INITIAL_FOOD_CELL := Vector2i(11, 10)
