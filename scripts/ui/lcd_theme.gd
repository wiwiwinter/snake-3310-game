class_name LcdTheme
extends RefCounted
## Builds a shared monochrome green LCD Theme for menus, overlays, and keypad controls.


static func create_theme() -> Theme:
	var theme := Theme.new()

	# Standard LCD buttons (inside the #9BBC0F screen)
	var btn_normal := _make_box(GameConfig.COLOR_LCD_BG, GameConfig.COLOR_LCD_DEEP, 2)
	var btn_focus := _make_box(GameConfig.COLOR_LCD_DEEP, GameConfig.COLOR_LCD_DEEP, 2)
	var btn_pressed := _make_box(GameConfig.COLOR_LCD_DARK, GameConfig.COLOR_LCD_DEEP, 2)

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_focus)
	theme.set_stylebox("focus", "Button", btn_focus)
	theme.set_stylebox("pressed", "Button", btn_pressed)

	theme.set_color("font_color", "Button", GameConfig.COLOR_LCD_DEEP)
	theme.set_color("font_hover_color", "Button", GameConfig.COLOR_LCD_BG)
	theme.set_color("font_focus_color", "Button", GameConfig.COLOR_LCD_BG)
	theme.set_color("font_pressed_color", "Button", GameConfig.COLOR_LCD_BG)
	theme.set_color("font_color", "Label", GameConfig.COLOR_LCD_DEEP)

	# LCD frame panel
	var panel_box := _make_box(GameConfig.COLOR_LCD_BG, GameConfig.COLOR_LCD_DEEP, 3)
	theme.set_stylebox("panel", "PanelContainer", panel_box)

	return theme


static func style_keypad_button(button: Button) -> void:
	# High-contrast tactile keypad buttons placed on the dark-green outer bezel.
	var normal := _make_box(GameConfig.COLOR_LCD_DEEP, GameConfig.COLOR_LCD_LIGHT, 2)
	var active := _make_box(GameConfig.COLOR_LCD_BG, GameConfig.COLOR_LCD_DEEP, 2)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", active)
	button.add_theme_stylebox_override("focus", active)
	button.add_theme_stylebox_override("pressed", active)
	button.add_theme_color_override("font_color", GameConfig.COLOR_LCD_BG)
	button.add_theme_color_override("font_hover_color", GameConfig.COLOR_LCD_DEEP)
	button.add_theme_color_override("font_focus_color", GameConfig.COLOR_LCD_DEEP)
	button.add_theme_color_override("font_pressed_color", GameConfig.COLOR_LCD_DEEP)


static func _make_box(bg: Color, border: Color, border_w: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_w)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box
