# Development Plan — Snake 3310

## Current Status

- **Active Phase:** Phase 8 Complete (Desktop/Headless Verified), ready for Phase 9 (Android Packaging & Google Play Preparation)
- **Overall Progress:** 8 / 9 Phases Complete

---

## Phase Roadmap & Checklist

### Phase 1: Environment and Project Initialization
- [x] Inspect workspace and initial development tools
- [x] Create initial documentation (`README.md`, `GUIDE.md`, `DEVELOPMENT_PLAN.md`, `REQUIREMENTS.md`, `CHANGELOG.md`)
- [x] Verify Godot 4.x installation and version (`4.7.2.stable.official.ed1daf0bf`)
- [x] Verify JDK 17 (`17.0.21+9`) and Android SDK command-line tools (`platform-tools`, `build-tools;35.0.1`, `platforms;android-35`)
- [x] Configure VS Code for GDScript development (`geequlim.godot-tools` v2.7.1 + `.vscode/settings.json`)
- [x] Initialize Godot 4 project (`project.godot`) and initial display/input settings
- [x] Create project folder structure (`scenes/`, `scripts/`, `assets/`, `tests/`, `android/`)
- [x] Initialize Git repository (`main` branch) and configure `.gitignore`
- [x] Verify initial project launch (`scenes/main/main.tscn` executed cleanly via Godot 4.7.2)

### Phase 2: Core Game Rendering
- [x] Create main game scene (`scenes/game/game_scene.tscn` & `scripts/gameplay/game_scene.gd`)
- [x] Implement grid system and coordinate mapping (`scripts/gameplay/grid_system.gd`, 16×20 @ 18px)
- [x] Configure monochrome LCD-inspired background and framing (`scripts/core/game_config.gd`)
- [x] Create snake visual representation (head with directional eyes, segmented body, tapered tail)
- [x] Create food visual representation (classic 3310-style monochrome pixel diamond)
- [x] Verify basic rendering (headless launch + `tests/test_phase2_rendering.gd` passed)

### Phase 3: Snake Movement
- [x] Implement grid-based movement loop and step timer (`scripts/gameplay/game_scene.gd`, fixed-step accumulator)
- [x] Implement directional controls (Arrow/WASD input actions + public `request_direction()` API)
- [x] Implement input buffering and prevent immediate 180-degree reversals (`scripts/gameplay/snake_controller.gd`)
- [x] Verify movement consistency (`tests/test_phase3_movement.gd` + `tests/test_phase2_rendering.gd` passed)

### Phase 4: Food and Collision Detection
- [x] Implement random food spawning on valid unoccupied cells (`scripts/gameplay/snake_game_session.gd`)
- [x] Detect food consumption and grow snake
- [x] Implement wall collision and configurable wraparound mode (`wrap_walls`)
- [x] Implement self-collision detection (including vacating-tail edge case)
- [x] Trigger Game Over state, board-cleared handling, and restart flow (`Enter` / `Space` / `R`)
- [x] Add automated tests for core gameplay logic (`tests/test_phase4_gameplay.gd`)

### Phase 5: Scoring and Difficulty
- [x] Implement current score tracking and reset on new game (`scripts/managers/score_manager.gd`)
- [x] Implement persistent local high-score storage (`ConfigFile` at `user://snake3310_save.cfg`, overall + per-difficulty)
- [x] Implement Easy / Normal / Hard difficulty levels affecting speed (`0.22s`, `0.15s`, `0.095s`)
- [x] Display score, high score, and difficulty in HUD (`scenes/game/game_scene.tscn`)

### Phase 6: UI/UX Implementation
- [x] Create Splash Screen (`scenes/menu/splash_screen.tscn`)
- [x] Create Main Menu (`scenes/menu/main_menu.tscn`)
- [x] Create Pause Screen (`PauseOverlay` in `scenes/game/game_scene.tscn`)
- [x] Create Game Over Screen (`GameOverOverlay` in `scenes/game/game_scene.tscn`)
- [x] Create Settings Screen (`scenes/settings/settings_screen.tscn`: speed, walls, SFX, music)
- [x] Create High Score Screen (`scenes/menu/high_score_screen.tscn`)
- [x] Implement structured game-state navigation (`Splash`, `Main Menu`, `Ready`, `Playing`, `Paused`, `Game Over`)
- [x] Implement on-screen directional buttons (>= 44px tap targets) and swipe gestures (`scripts/ui/swipe_detector.gd`)
- [x] Optimize portrait layout, monochrome LCD theme (`scripts/ui/lcd_theme.gd`), and Android focus-loss auto-pause

### Phase 7: Audio and Polish
- [x] Add original retro-inspired sound effects (`scripts/managers/audio_manager.gd`: eat, click, game over, win)
- [x] Add optional retro background music (procedural 8-bit chiptune loop)
- [x] Add sound/music toggles in Settings (live `audio_settings_changed` hook)
- [x] Add subtle transitions (`Main` 120ms LCD fade) and visual feedback (`BoardRenderer` eat/collision flash)

### Phase 8: Testing and Optimization
- [x] Test gameplay mechanics and edge cases (`test_phase3_movement.gd`, `test_phase4_gameplay.gd`)
- [x] Test collision detection (solid walls, wraparound, self-collision, vacating tail, full grid)
- [x] Test score and settings persistence (`test_phase5_scoring.gd`, `test_phase6_ui.gd`)
- [x] Test multiple portrait screen resolutions and aspect ratios (`360x640`, `360x780`, `360x800`, `412x915` in `test_phase8_integration.gd`)
- [x] Test touchscreen controls (D-pad >= 44px tap targets + `SwipeDetector`)
- [x] Test pause, resume, Android Back button (`NOTIFICATION_WM_GO_BACK_REQUEST`), and app-background auto-pause
- [x] Profile performance (`10,000` ticks in `33.84 ms` = `0.0034 ms/tick`) and verify zero script errors

### Phase 9: Android Packaging and Google Play Preparation
- [ ] Configure Android export presets (package ID, app name, version code/name)
- [ ] Prepare original app icon and adaptive icon assets
- [ ] Configure release signing keystore securely (outside Git)
- [ ] Build and verify debug/release APK locally
- [ ] Build and verify signed AAB for Google Play
- [ ] Prepare store listing assets (screenshots, feature graphic, description)
- [ ] Review current Google Play target API, Privacy Policy, and Data Safety requirements
- [ ] Prepare internal/closed testing track

---

## Known Limitations & Notes (Current)

1. **Godot 4.7.2 Export Templates:** Not yet downloaded; will be installed in Phase 9 to generate APK and signed AAB builds.
2. **Physical Android Device Testing:** `adb devices` reported no connected device/emulator during Phase 8; on-device touch and performance validation should be run once the Phase 9 APK is built and installed on an Android phone.
