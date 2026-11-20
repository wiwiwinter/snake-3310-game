class_name GameConfig
extends RefCounted
## Shared visual palette and grid configuration constants for Snake 3310.

# Default Nokia 3310 monochrome green LCD constants
const COLOR_LCD_BG := Color("#9BBC0F")       # Primary LCD background
const COLOR_LCD_LIGHT := Color("#8BAC0F")    # Subtle grid lines / secondary background
const COLOR_LCD_DARK := Color("#306230")     # Outer framing / muted accents
const COLOR_LCD_DEEP := Color("#0F380F")     # Active LCD pixels (snake, food, borders, text)

# Selectable retro monochrome handheld colorways (all 4-shade, WCAG AAA contrast)
enum ColorTheme {
	NOKIA_GREEN,
	POCKET_GRAY,
	AMBER_LCD,
	ICE_BLUE,
}

const COLOR_THEMES: Dictionary = {
	ColorTheme.NOKIA_GREEN: {
		"name": "NOKIA GREEN",
		"bg": Color("#9BBC0F"),
		"light": Color("#8BAC0F"),
		"dark": Color("#306230"),
		"deep": Color("#0F380F"),
		"hi": Color("#B8D926"),
	},
	ColorTheme.POCKET_GRAY: {
		"name": "POCKET GRAY",
		"bg": Color("#C8D0C8"),
		"light": Color("#A8B2A8"),
		"dark": Color("#545E54"),
		"deep": Color("#181E18"),
		"hi": Color("#E0E8E0"),
	},
	ColorTheme.AMBER_LCD: {
		"name": "AMBER LCD",
		"bg": Color("#F5B841"),
		"light": Color("#D99B26"),
		"dark": Color("#6E4208"),
		"deep": Color("#261400"),
		"hi": Color("#FFD275"),
	},
	ColorTheme.ICE_BLUE: {
		"name": "ICE BLUE",
		"bg": Color("#7CE0F0"),
		"light": Color("#5BC4D6"),
		"dark": Color("#1F5C70"),
		"deep": Color("#082430"),
		"hi": Color("#A8F0FC"),
	},
}

static var active_theme: ColorTheme = ColorTheme.NOKIA_GREEN
static var color_lcd_bg: Color = COLOR_LCD_BG
static var color_lcd_light: Color = COLOR_LCD_LIGHT
static var color_lcd_dark: Color = COLOR_LCD_DARK
static var color_lcd_deep: Color = COLOR_LCD_DEEP
static var color_lcd_hi: Color = Color("#B8D926")


static func apply_color_theme(theme_id: ColorTheme) -> void:
	var t: Dictionary = COLOR_THEMES.get(theme_id, COLOR_THEMES[ColorTheme.NOKIA_GREEN])
	active_theme = theme_id if COLOR_THEMES.has(theme_id) else ColorTheme.NOKIA_GREEN
	color_lcd_bg = t["bg"]
	color_lcd_light = t["light"]
	color_lcd_dark = t["dark"]
	color_lcd_deep = t["deep"]
	color_lcd_hi = t["hi"]


static func get_color_theme_name(theme_id: ColorTheme) -> String:
	var t: Dictionary = COLOR_THEMES.get(theme_id, COLOR_THEMES[ColorTheme.NOKIA_GREEN])
	return str(t["name"])

# Grid dimensions (16x20 at 18px = 288x360 px playable LCD area)
const GRID_COLUMNS: int = 16
const GRID_ROWS: int = 20
const CELL_SIZE: int = 18

# Movement timing and input buffering
const DEFAULT_MOVE_INTERVAL: float = 0.15
const MAX_INPUT_QUEUE_SIZE: int = 2

# Scoring & difficulty settings
enum Difficulty {
	EASY,
	NORMAL,
	HARD,
}

const POINTS_PER_FOOD: int = 10
const SAVE_FILE_PATH: String = "user://snake3310_save.cfg"

const DIFFICULTY_INTERVALS: Dictionary = {
	Difficulty.EASY: 0.22,
	Difficulty.NORMAL: 0.15,
	Difficulty.HARD: 0.095,
}

const DIFFICULTY_NAMES: Dictionary = {
	Difficulty.EASY: "EASY",
	Difficulty.NORMAL: "NORMAL",
	Difficulty.HARD: "HARD",
}

# Default initial placement for Phase 2 rendering & new game resets
const INITIAL_SNAKE_CELLS: Array[Vector2i] = [
	Vector2i(6, 10),
	Vector2i(5, 10),
	Vector2i(4, 10),
	Vector2i(3, 10),
]
const INITIAL_DIRECTION := Vector2i.RIGHT
const INITIAL_FOOD_CELL := Vector2i(11, 10)


static func get_move_interval(difficulty: Difficulty) -> float:
	return float(DIFFICULTY_INTERVALS.get(difficulty, DEFAULT_MOVE_INTERVAL))


static func get_difficulty_name(difficulty: Difficulty) -> String:
	return str(DIFFICULTY_NAMES.get(difficulty, "NORMAL"))
