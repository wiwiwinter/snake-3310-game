# Changelog — Snake 3310

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
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
