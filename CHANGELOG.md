# Changelog — Snake 3310

All notable changes to this project will be documented in this file.

## [Unreleased]

### Fixed
- Applied all 6 `/ponytail-audit` optimizations: adaptive LCD playfield sizing (auto-expands rows and cell size to fill tall screens with zero empty band), playfield-only swipe bounds (prevents Pause/Restart slip turns), stopped hidden-screen redraws (`BoardRenderer`/`SplashScreen`), Android app-background music pause/resume, deduplicated `LcdTheme` to 3 monochrome variants (`LCD_PRIMARY`, `LCD_SECONDARY`, `HANDHELD_DARK`), removed per-draw food array allocation, and made music WAV synthesis lazy.
- Replaced separate D-pad buttons with a unified monochrome `CircularDpad` (`scripts/ui/circular_dpad.gd`, `184x184`) flanked by pixel-icon Pause/Restart buttons supporting continuous 360-degree hold-and-roll thumb motion across all 4 quadrants with live wedge highlighting.
- Fixed Android touch/swipe gestures and Splash tap-to-skip being swallowed by `Control` panels (`_unhandled_input` -> `_input`), filtered multi-touch to primary finger (`index == 0`), prevented duplicate `emulate_mouse_from_touch` drag events on Android, and tightened swipe threshold to `22px`.

### Added
- **Phase 9: Android Packaging & Modern-Retro UI Polish**
  - Enabled `textures/vram_compression/import_etc2_astc=true` in `project.godot` for Android export compatibility and bumped version to `1.0.0`.
  - Installed Godot `4.7.2.stable` Export Templates, generated and verified `android/build/snake3310-debug.apk` (`54.9 MB`, APK Signature Scheme v2 & v3 verified via `apksigner`).
  - Tuned tall-phone Android layout (Nothing Phone 3a Lite): compact LCD frame, larger `74x52` D-pad (`26px` arrows, `24x24` center pivot), `108x38` Pause/Restart buttons, `56-60px` menu buttons, detailed 32x32 pixel-art snake icon (`app_icon.svg`), animated `MenuSnakeBanner`, Splash loading bar, and dynamic Android camera-cutout safe-area top inset (`>= 42px`).
  - Added recessed 9-slice handheld LCD frame styling and crisp pixel label shadows in `scripts/ui/lcd_theme.gd`.
  - Added original monochrome pixel-art snake emblem (`assets/sprites/app_icon.svg`) to `project.godot`, Splash Screen, and Main Menu (`DOT MATRIX · MONO LCD` header).
  - Added central D-pad pivot block in `scenes/game/game_scene.tscn` and a 2-state retro LCD food pulse in `scripts/gameplay/board_renderer.gd`.
  - Configured Godot 4.7 Android SDK / JDK 17 / debug keystore settings and gitignored `export_presets.cfg` (`com.wiwiwinter.snake3310`, `v1.0.0`, API 35).
  - Added `android/PLAY_STORE_LISTING.md` and `android/PRIVACY_POLICY.md`.
- **Phase 8: Testing and Optimization**
  - Added Android system Back button (`NOTIFICATION_WM_GO_BACK_REQUEST`) handling in `scripts/core/main.gd`.
  - Added `tests/test_phase8_integration.gd` covering multi-resolution portrait bounds (`360x640`, `360x780`, `360x800`, `412x915`), Android lifecycle pause/back notifications, end-to-end saved-settings integration, and a 10,000-tick performance benchmark (`33.84 ms`).
  - Executed and verified all 7 automated test suites (`test_phase2_rendering.gd` through `test_phase8_integration.gd`).
  - Upgraded UI buttons in `scripts/ui/lcd_theme.gd` to procedural 9-slice monochrome Game Boy pixel-bevel buttons (stepped corners, top shine, chunky 3D bottom lip, press-down shift, tonal monochrome green hierarchy, and `▲/▼/◀/▶` D-pad glyphs).
- **Phase 7: Audio and Polish**
  - Added `scripts/managers/audio_manager.gd` synthesizing original 16-bit PCM `AudioStreamWAV` piezo SFX (`eat`, `click`, `game_over`, `win`) and an optional looping chiptune background melody.
  - Wired live `SFX` and `MUSIC` settings toggles from `SettingsScreen` to `AudioManager`.
  - Added eat/collision LCD flash feedback to `scripts/gameplay/board_renderer.gd` and subtle 120ms screen transitions to `scripts/core/main.gd`.
  - Added `tests/test_phase7_audio.gd` automated audio and visual feedback test suite.
- **Phase 6: UI/UX Implementation**
  - Added shared monochrome LCD theme (`scripts/ui/lcd_theme.gd`) and cardinal swipe detector (`scripts/ui/swipe_detector.gd`).
  - Added Splash Screen (`scenes/menu/splash_screen.tscn`), Main Menu (`scenes/menu/main_menu.tscn`), Settings Screen (`scenes/settings/settings_screen.tscn`), and High Score Screen (`scenes/menu/high_score_screen.tscn`).
  - Added Ready, Pause, and Game Over LCD overlays, tactile on-screen D-pad (>= 44px tap targets), swipe gestures, and Android focus-loss auto-pause to `scenes/game/game_scene.tscn` and `scripts/gameplay/game_scene.gd`.
  - Wired root screen navigation in `scenes/main/main.tscn` and `scripts/core/main.gd`.
  - Extended `scripts/managers/score_manager.gd` to persist `wrap_walls`, `sfx_enabled`, and `music_enabled`.
  - Added `tests/test_phase6_ui.gd` automated UI, swipe, tap-target, and navigation test suite.
- **Phase 5: Scoring and Difficulty**
  - Added `GameConfig.Difficulty` (`EASY`: `0.22s`, `NORMAL`: `0.15s`, `HARD`: `0.095s`), `POINTS_PER_FOOD` (`10`), and `SAVE_FILE_PATH` to `scripts/core/game_config.gd`.
  - Added `scripts/managers/score_manager.gd` for score tracking, overall and per-difficulty high-score persistence (`ConfigFile`), and safe fallback on corrupt/missing saves.
  - Updated `scenes/game/game_scene.tscn` and `scripts/gameplay/game_scene.gd` HUD to display `SCR`, `HI`, and active difficulty, with `1`/`2`/`3` desktop shortcuts for testing speeds.
  - Added `tests/test_phase5_scoring.gd` automated scoring, persistence, and difficulty test suite.
- **Phase 4: Food and Collision Detection**
  - Added `scripts/gameplay/snake_game_session.gd` implementing random unoccupied food spawning, food consumption and snake growth, solid-wall and configurable wraparound modes, self-collision (with vacating-tail edge case), board-cleared handling, Game Over state, and reset.
  - Updated `scripts/gameplay/game_scene.gd` to run `SnakeGameSession` ticks, display Game Over / Win feedback, and restart via `Enter`, `Space`, or `R`.
  - Added `tests/test_phase4_gameplay.gd` automated gameplay test suite.
- **Phase 3: Snake Movement**
  - Added `scripts/gameplay/snake_controller.gd` managing snake segments, cardinal direction checks, 2-step turn input buffering, and 180-degree reversal prevention.
  - Added fixed-step movement timing and Arrow/WASD directional handling (`request_direction`) to `scripts/gameplay/game_scene.gd`.
  - Added `DEFAULT_MOVE_INTERVAL` and `MAX_INPUT_QUEUE_SIZE` constants to `scripts/core/game_config.gd`.
  - Added `tests/test_phase3_movement.gd` automated movement test suite.
- **Phase 2: Core Game Rendering**
  - Added `scripts/core/game_config.gd` centralizing the Nokia 3310 monochrome LCD palette and 16×20 (`18px` cell) grid constants.
  - Added `scripts/gameplay/grid_system.gd` for discrete grid bounds checking, wraparound, and local pixel coordinate mapping.
  - Added `scripts/gameplay/board_renderer.gd` using crisp `_draw()` pixel rendering for the LCD background, subtle grid lines, inner border, snake (directional head with eyes, segmented body, tail), and retro diamond food.
  - Added `scenes/game/game_scene.tscn` and `scripts/gameplay/game_scene.gd` with monochrome LCD bezel framing, HUD bar, centered playfield, and Phase 6 touch-control deck placeholder.
  - Wired `scenes/main/main.tscn` to instantiate `GameScene`.
  - Added `tests/test_phase2_rendering.gd` automated headless verification suite.
- **Phase 1: Environment and Project Initialization**
  - Installed and verified Godot Engine `4.7.2.stable`, Eclipse Temurin OpenJDK `17.0.21+9`, Android SDK Command-Line Tools (`platform-tools`, `build-tools;35.0.1`, `platforms;android-35`), and VS Code `geequlim.godot-tools` (`v2.7.1`).
  - Configured `project.godot` for portrait mobile display (`360x640`, `canvas_items`/`expand`, `gl_compatibility`, Nearest pixel filtering) and core input actions (`move_up`, `move_down`, `move_left`, `move_right`, `pause_game`).
  - Created modular folder structure (`scenes/`, `scripts/`, `assets/`, `tests/`, `android/`).
  - Added bootstrap scene `scenes/main/main.tscn` and script `scripts/core/main.gd`.
  - Added `.gitignore`, `.vscode/settings.json`, and `.vscode/extensions.json`.
  - Initialized Git repository on `main`.
- Created initial project documentation: `README.md`, `GUIDE.md`, `DEVELOPMENT_PLAN.md`, `REQUIREMENTS.md`, and `CHANGELOG.md`.
- Completed initial workspace and development environment inspection.
