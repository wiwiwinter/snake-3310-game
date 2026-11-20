class_name LcdTheme
extends RefCounted
## Shared monochrome LCD theme, recessed handheld bezel, pixel icons, and 9-slice pixel-bevel buttons.

enum ButtonVariant {
	LCD_PRIMARY,
	LCD_SECONDARY,
	HANDHELD_DARK,
}

# Original 4-shade monochrome LCD palette: bright LCD buttons on screen, dark handheld keys on deck.
const PALETTES: Dictionary = {
	ButtonVariant.LCD_PRIMARY: {
		"fill": Color("#9BBC0F"),
		"highlight": Color("#B8D926"),
		"shadow": Color("#8BAC0F"),
		"hover": Color("#AED01A"),
		"outline": Color("#0F380F"),
		"ink": Color("#0F380F"),
	},
	ButtonVariant.LCD_SECONDARY: {
		"fill": Color("#8BAC0F"),
		"highlight": Color("#9BBC0F"),
		"shadow": Color("#306230"),
		"hover": Color("#9BBC0F"),
		"outline": Color("#0F380F"),
		"ink": Color("#0F380F"),
	},
	ButtonVariant.HANDHELD_DARK: {
		"fill": Color("#306230"),
		"highlight": Color("#8BAC0F"),
		"shadow": Color("#0F380F"),
		"hover": Color("#3E7A3E"),
		"outline": Color("#0F380F"),
		"ink": Color("#9BBC0F"),
	},
}

static var _cached_styleboxes: Dictionary = {}


static func create_theme() -> Theme:
	var theme := Theme.new()

	var primary_boxes: Dictionary = _get_variant_boxes(ButtonVariant.LCD_PRIMARY)
	var primary_ink: Color = PALETTES[ButtonVariant.LCD_PRIMARY]["ink"]

	theme.set_stylebox("normal", "Button", primary_boxes["normal"])
	theme.set_stylebox("hover", "Button", primary_boxes["hover"])
	theme.set_stylebox("focus", "Button", primary_boxes["focus"])
	theme.set_stylebox("pressed", "Button", primary_boxes["pressed"])

	theme.set_color("font_color", "Button", primary_ink)
	theme.set_color("font_hover_color", "Button", primary_ink)
	theme.set_color("font_focus_color", "Button", primary_ink)
	theme.set_color("font_pressed_color", "Button", primary_ink)
	theme.set_color("font_color", "Label", GameConfig.COLOR_LCD_DEEP)
	theme.set_color("font_shadow_color", "Label", GameConfig.COLOR_LCD_LIGHT)
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)

	theme.set_stylebox("panel", "PanelContainer", _make_lcd_frame_stylebox())
	return theme


static func apply_pixel_button(button: Button, variant: ButtonVariant) -> void:
	if button == null:
		return
	var boxes: Dictionary = _get_variant_boxes(variant)
	var ink: Color = PALETTES[variant]["ink"]

	button.add_theme_stylebox_override("normal", boxes["normal"])
	button.add_theme_stylebox_override("hover", boxes["hover"])
	button.add_theme_stylebox_override("focus", boxes["focus"])
	button.add_theme_stylebox_override("pressed", boxes["pressed"])
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_focus_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)


static func make_pause_icon() -> ImageTexture:
	return _build_pixel_icon([
		"................",
		"................",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"....###..###....",
		"................",
		"................",
	])


static func make_play_icon() -> ImageTexture:
	return _build_pixel_icon([
		"................",
		"................",
		"....##..........",
		"....####........",
		"....######......",
		"....########....",
		"....##########..",
		"....###########.",
		"....###########.",
		"....##########..",
		"....########....",
		"....######......",
		"....####........",
		"....##..........",
		"................",
		"................",
	])


static func make_restart_icon() -> ImageTexture:
	return _build_pixel_icon([
		"................",
		"......######....",
		"....##......##..",
		"...##........##.",
		"..##......#...#.",
		"..##.......##.#.",
		"..##......#####.",
		"..##............",
		"..##............",
		"..##..........#.",
		"..##.........##.",
		"...##.......##..",
		"....##.....##...",
		"......#####.....",
		"................",
		"................",
	])


static func _build_pixel_icon(rows: Array[String]) -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(mini(16, rows.size())):
		var line: String = rows[y]
		for x in range(mini(16, line.length())):
			if line[x] == "#":
				img.set_pixel(x, y, GameConfig.COLOR_LCD_BG)
	return ImageTexture.create_from_image(img)


static func _make_lcd_frame_stylebox() -> StyleBoxTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(GameConfig.COLOR_LCD_BG)

	for y in range(16):
		for x in range(16):
			var is_corner: bool = (x == 0 or x == 15) and (y == 0 or y == 15)
			if is_corner:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif x == 0 or x == 15 or y == 0 or y == 15:
				img.set_pixel(x, y, GameConfig.COLOR_LCD_DEEP)
			elif x == 1 or x == 14 or y == 1 or y == 14:
				img.set_pixel(x, y, GameConfig.COLOR_LCD_DARK if (y == 1 or x == 1) else GameConfig.COLOR_LCD_LIGHT)
			elif y == 2 or x == 2:
				img.set_pixel(x, y, GameConfig.COLOR_LCD_LIGHT)

	var tex := ImageTexture.create_from_image(img)
	var box := StyleBoxTexture.new()
	box.texture = tex
	box.texture_margin_left = 4.0
	box.texture_margin_right = 4.0
	box.texture_margin_top = 4.0
	box.texture_margin_bottom = 4.0
	return box


static func _get_variant_boxes(variant: ButtonVariant) -> Dictionary:
	if _cached_styleboxes.has(variant):
		return _cached_styleboxes[variant]

	var p: Dictionary = PALETTES[variant]
	var boxes: Dictionary = {
		"normal": _make_pixel_stylebox(p["fill"], p["highlight"], p["shadow"], p["outline"], false, false),
		"hover": _make_pixel_stylebox(p["hover"], p["highlight"], p["shadow"], p["outline"], false, false),
		"focus": _make_pixel_stylebox(p["hover"], p["highlight"], p["shadow"], p["outline"], false, true),
		"pressed": _make_pixel_stylebox(p["fill"], p["shadow"], p["shadow"], p["outline"], true, false),
	}
	_cached_styleboxes[variant] = boxes
	return boxes


static func _make_pixel_stylebox(
	fill: Color,
	highlight: Color,
	shadow: Color,
	outline: Color,
	pressed: bool,
	focused: bool
) -> StyleBoxTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var top_y: int = 2 if pressed else 0
	var bot_y: int = 15

	for y in range(top_y, bot_y + 1):
		for x in range(16):
			if (x == 0 or x == 15) and (y == top_y or y == bot_y):
				continue
			var is_outline: bool = (
				x == 0 or x == 15 or y == top_y or y == bot_y
				or ((x == 1 or x == 14) and (y == top_y + 1 or y == bot_y - 1))
			)
			if is_outline:
				img.set_pixel(x, y, outline)
			elif not pressed and y >= bot_y - 2:
				img.set_pixel(x, y, shadow)
			elif y == top_y + 1 or (focused and (x == 1 or x == 14)):
				img.set_pixel(x, y, highlight)
			else:
				img.set_pixel(x, y, fill)

	var tex := ImageTexture.create_from_image(img)
	var box := StyleBoxTexture.new()
	box.texture = tex
	box.texture_margin_left = 4.0
	box.texture_margin_right = 4.0
	box.texture_margin_top = 5.0
	box.texture_margin_bottom = 5.0
	box.content_margin_left = 10.0
	box.content_margin_right = 10.0
	box.content_margin_top = 10.0 if pressed else 7.0
	box.content_margin_bottom = 6.0 if pressed else 9.0
	return box
