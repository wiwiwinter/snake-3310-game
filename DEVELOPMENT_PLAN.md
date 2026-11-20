# Development Plan — Snake 3310

## Current Status

- **Active Phase:** Phase 3 Complete, ready for Phase 4 (Food and Collision Detection)
- **Overall Progress:** 3 / 9 Phases Complete

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
- [ ] Implement random food spawning on valid unoccupied cells
- [ ] Detect food consumption and grow snake
- [ ] Implement wall collision and configurable wraparound mode
- [ ] Implement self-collision detection
- [ ] Trigger Game Over state and restart flow
- [ ] Add automated tests for core gameplay logic

### Phase 5: Scoring and Difficulty
- [ ] Implement current score tracking and reset on new game
- [ ] Implement persistent local high-score storage
- [ ] Implement Easy / Normal / Hard difficulty levels affecting speed
- [ ] Display score and high score in HUD

### Phase 6: UI/UX Implementation
- [ ] Create Splash Screen
- [ ] Create Main Menu
- [ ] Create Pause Screen
- [ ] Create Game Over Screen
- [ ] Create Settings Screen (difficulty, wall mode, audio toggles)
- [ ] Create High Score Screen
- [ ] Implement structured game-state navigation (`Main Menu`, `Ready`, `Playing`, `Paused`, `Game Over`)
- [ ] Implement on-screen directional buttons and swipe gestures
- [ ] Optimize portrait layout for varying Android aspect ratios

### Phase 7: Audio and Polish
- [ ] Add original retro-inspired sound effects (eat, turn/UI click, game over)
- [ ] Add optional retro background music
- [ ] Add sound/music toggles in Settings
- [ ] Add subtle transitions and visual feedback

### Phase 8: Testing and Optimization
- [ ] Test gameplay mechanics and edge cases
- [ ] Test collision detection (solid walls, wraparound, self-collision, full grid)
- [ ] Test score and settings persistence
- [ ] Test multiple portrait screen resolutions and aspect ratios
- [ ] Test touchscreen buttons and swipe gestures
- [ ] Test pause, resume, and Android app backgrounding behavior
- [ ] Profile performance and fix any issues

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

1. **Godot 4.7.2 Export Templates:** Not yet downloaded; will be installed when preparing Android exports in Phase 9 (or earlier if testing on-device in Phase 8).
