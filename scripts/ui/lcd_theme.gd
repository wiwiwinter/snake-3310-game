class_name LcdTheme
extends RefCounted
## Shared monochrome LCD theme for the game screen plus tactile 9-slice pixel-bevel arcade buttons.

enum ButtonVariant {
	GREEN,
	AMBER,
	CYAN,
	RED,
}

# Original 4-shade monochrome LCD palette: bright LCD buttons everywhere, darker Game Boy D-pad only.
const PALETTES: Dictionary = {
	ButtonVariant.GREEN: {
		"fill": Color("#9BBC0F"),
		"highlight": Color("#B8D926"),
		"shadow": Color("#8BAC0F"),
		"hover": Color("#AED01A"),
		"outline": Color("#0F380F"),
		"ink": Color("#0F380F"),
	},
	ButtonVariant.CYAN: {
		# Classic darker Game Boy D-pad only
		"fill": Color("#306230"),
		"highlight": Color("#8BAC0F"),
		"shadow": Color("#0F380F"),
		"hover": Color("#3E7A3E"),
		"outline": Color("#0F380F"),
		"ink": Color("#9BBC0F"),
	},
	ButtonVariant.AMBER: {
		"fill": Color("#9BBC0F"),
		"highlight": Color("#B8D926"),
		"shadow": Color("#8BAC0F"),
		"hover": Color("#AED01A"),
		"outline": Color("#0F380F"),
		"ink": Color("#0F380F"),
	},
	ButtonVariant.RED: {
		"fill": Color("#8BAC0F"),
		"highlight": Color("#9BBC0F"),
		"shadow": Color("#306230"),
		"hover": Color("#9BBC0F"),
		"outline": Color("#0F380F"),
		"ink": Color("#0F380F"),
	},
}

static var _cached_styleboxes: Dictionary = {}


static func create_theme() -> Theme:
	var theme := Theme.new()

	# Default Button style uses the energetic retro green pixel bevel.
	var green_boxes: Dictionary = _get_variant_boxes(ButtonVariant.GREEN)
	var green_ink: Color = PALETTES[ButtonVariant.GREEN]["ink"]

	theme.set_stylebox("normal", "Button", green_boxes["normal"])
	theme.set_stylebox("hover", "Button", green_boxes["hover"])
	theme.set_stylebox("focus", "Button", green_boxes["focus"])
	theme.set_stylebox("pressed", "Button", green_boxes["pressed"])

	theme.set_color("font_color", "Button", green_ink)
	theme.set_color("font_hover_color", "Button", green_ink)
	theme.set_color("font_focus_color", "Button", green_ink)
	theme.set_color("font_pressed_color", "Button", green_ink)
	theme.set_color("font_color", "Label", GameConfig.COLOR_LCD_DEEP)
	theme.set_color("font_shadow_color", "Label", GameConfig.COLOR_LCD_LIGHT)
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)

	# Recessed retro handheld LCD screen panel (stepped dark frame + inner top shadow).
	theme.set_stylebox("panel", "PanelContainer", _make_lcd_frame_stylebox())

	return theme


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
				# Recessed inner rim: darker on top/left, lighter on bottom/right
				if y == 1 or x == 1:
					img.set_pixel(x, y, GameConfig.COLOR_LCD_DARK)
				else:
					img.set_pixel(x, y, GameConfig.COLOR_LCD_LIGHT)
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
	# 16x16 pixel-art 9-slice with stepped 1px chamfered corners, top shine, and chunky 3D bottom lip.
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var top_y: int = 2 if pressed else 0
	var bot_y: int = 15

	for y in range(top_y, bot_y + 1):
		for x in range(16):
			# Step-chamfer the 4 outer corners for an authentic retro pixel silhouette.
			var is_corner: bool = (
				(x == 0 or x == 15) and (y == top_y or y == bot_y)
			)
			if is_corner:
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
