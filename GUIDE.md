# Developer Guide — Snake 3310

This guide covers environment setup, project architecture, running and testing the game, and exporting Android builds.

---

## 1. Required Software

| Tool | Purpose | Required Version |
| :--- | :--- | :--- |
| **Godot Engine** | Game engine, scene editor, runtime, and Android export | Godot 4.x (Standard edition, GDScript) |
| **Visual Studio Code** | Primary source-code editor | Latest stable |
| **VS Code Extension: `godot-tools`** | GDScript syntax highlighting, LSP, and debugging | Latest |
| **OpenJDK (JDK 17)** | Required by Godot 4 Android Gradle builds & `keytool` | JDK 17 (LTS) |
| **Android SDK Command-Line Tools** | `sdkmanager`, `platform-tools` (`adb`), build tools, Android platforms | Latest cmdline-tools |
| **Godot Export Templates** | Required by Godot to export APK/AAB | Matching installed Godot 4.x version |
| **Git** | Version control | 2.x+ |

---

## 2. Environment Setup (Windows)

### 2.1 Install Godot 4.x
1. Download the latest stable **Godot 4.x Standard** (not .NET) for Windows from [godotengine.org](https://godotengine.org/download/windows/).
2. Extract it to a stable folder (e.g., `C:\Tools\Godot\`).
3. Add that folder to your Windows `PATH` (or configure the executable path in VS Code's `godot-tools` extension) so `godot` can be invoked from the terminal.

### 2.2 Install OpenJDK 17
Godot 4 Android exports require **JDK 17** (Java 8 JRE is not sufficient).
1. Install **Eclipse Temurin JDK 17** (e.g., via `winget install EclipseAdoptium.Temurin.17.JDK` or from [adoptium.net](https://adoptium.net/)).
2. Set the `JAVA_HOME` environment variable to the JDK 17 installation directory and ensure `%JAVA_HOME%\bin` precedes any older Java entry in `PATH`.
3. Verify with `java -version`, `javac -version`, and `keytool -help`.

### 2.3 Install Android SDK Command-Line Tools (No Android Studio Required)
1. Download **Command line tools only** for Windows from [developer.android.com/studio#command-line-tools-only](https://developer.android.com/studio#command-line-tools-only).
2. Extract to `C:\Android\Sdk\cmdline-tools\latest\`.
3. Set `ANDROID_HOME=C:\Android\Sdk` (and `ANDROID_SDK_ROOT=C:\Android\Sdk`).
4. Add `%ANDROID_HOME%\cmdline-tools\latest\bin` and `%ANDROID_HOME%\platform-tools` to `PATH`.
5. Install required SDK packages using `sdkmanager` (exact API level will be confirmed against the installed Godot 4.x version and current Google Play target API requirements):
   ```powershell
   sdkmanager --licenses
   sdkmanager "platform-tools" "build-tools;34.0.0" "platforms;android-34"
   ```
   *(Adjust `build-tools` and `platforms` versions in Phase 9 to match Google Play's current target SDK requirement and Godot's Android export requirements.)*

### 2.4 Configure VS Code
1. Install the **`geequlim.godot-tools`** extension in VS Code.
2. In VS Code settings, point `godotTools.editorPath.godot4` to your Godot 4 executable.
3. In Godot Editor (`Editor -> Editor Settings -> Text Editor -> External`), enable **Use External Editor** and configure VS Code if desired.

---

## 3. Opening and Running the Project

Restart your terminal or VS Code window once after installation so the updated user `PATH`, `JAVA_HOME`, and `ANDROID_HOME` environment variables take effect.

- **From Godot Editor:** Open `d:\CODE\ANDROID GAME - SNAKE\project.godot` in Godot 4.7.2 and press `F5` to run.
- **From Command Line (GUI):**
  ```powershell
  godot --path "d:\CODE\ANDROID GAME - SNAKE"
  ```
- **From Command Line (Headless Verification):**
  ```powershell
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --quit-after 2
  ```

---

## 4. Testing the Game

- **Automated Headless Tests:**
  ```powershell
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase2_rendering.gd
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase3_movement.gd
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase4_gameplay.gd
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase5_scoring.gd
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase6_ui.gd
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase7_audio.gd
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --script res://tests/test_phase8_integration.gd
  ```
- **Visual / Manual Inspection:** Open the project in Godot 4.7.2 and press `F5` (or run `godot --path "d:\CODE\ANDROID GAME - SNAKE"`). Navigate menus via touch/click or keyboard (`Tab`/`Enter`/`Esc`), play using Arrow keys, WASD, on-screen D-pad, or mouse/touch swipes, and pause with `P` / `Esc` / `PAUSE`.

---

## 5. Exporting Android Builds

Godot 4.7.2 editor settings are configured with `C:\Android\Sdk`, OpenJDK 17, and `C:\Users\meepo\.android\debug.keystore`. Local export presets live in gitignored `export_presets.cfg` (`com.wiwiwinter.snake3310`, `v1.0.0`, target API `35`, `arm64-v8a` + `armeabi-v7a`).

- **Build local test APK (CLI):**
  ```powershell
  New-Item -ItemType Directory -Force -Path "d:\CODE\ANDROID GAME - SNAKE\android\build" | Out-Null
  godot_console --path "d:\CODE\ANDROID GAME - SNAKE" --headless --export-debug "Android APK" "android/build/snake3310-debug.apk"
  ```
- **Install on connected Android phone (USB Debugging enabled):**
  ```powershell
  adb install -r "d:\CODE\ANDROID GAME - SNAKE\android\build\snake3310-debug.apk"
  ```
- **Build signed Google Play AAB:**
  1. Generate a private release keystore outside this Git repo (see `android/PLAY_STORE_LISTING.md`).
  2. In Godot (`Project -> Export -> Android AAB (Google Play) -> Keystore`), set your release keystore path, user alias, and password.
  3. Export `android/build/snake3310-release.aab` (Gradle build enabled).

**Security Rule:** Never commit `.keystore`, `.jks`, signing passwords, or `export_presets.cfg` to Git (all are excluded by `.gitignore`).

---

## 6. Project Architecture & File Responsibilities

- `scenes/main/main.tscn` & `scripts/core/main.gd`: Root screen router (`Splash`, `MainMenu`, `GameScene`, `Settings`, `HighScores`) applying shared `LcdTheme`.
- `scenes/menu/` & `scenes/settings/`: Splash, Main Menu, High Score, and Settings screens with matching `scripts/ui/` controllers.
- `scripts/ui/lcd_theme.gd` & `scripts/ui/swipe_detector.gd`: Shared monochrome LCD `Theme` factory and touch/pointer swipe detector.
- `scenes/game/game_scene.tscn` & `scripts/gameplay/game_scene.gd`: Portrait LCD playfield, HUD strip, Ready/Pause/Game Over overlays, tactile D-pad, swipe input, and app-pause lifecycle hook.
- `scripts/core/game_config.gd`: Shared LCD color palette (`#9BBC0F`, `#8BAC0F`, `#306230`, `#0F380F`), grid dimensions (`16x20`, `18px` cells), difficulty intervals, and initial constants.
- `scripts/gameplay/grid_system.gd`: Pure 2D grid coordinate system (bounds checking, wraparound math, grid-to-pixel conversion).
- `scripts/gameplay/snake_controller.gd`: Snake segment state, cardinal direction validation, 2-step turn queue, and grid stepping.
- `scripts/gameplay/snake_game_session.gd`: Core Snake gameplay rules (random valid food spawning, growth, solid-wall/wraparound collision, self-collision, Game Over, and restart).
- `scripts/managers/score_manager.gd`: Current score tracking, persistent local high scores (overall and per-difficulty via `ConfigFile`), and saved game settings (`difficulty`, `wrap_walls`, `sfx_enabled`, `music_enabled`).
- `scripts/managers/audio_manager.gd`: Procedural 16-bit mono `AudioStreamWAV` synthesizer for Nokia-inspired piezo SFX and optional looping chiptune background music.
- `scripts/gameplay/board_renderer.gd`: Custom `_draw()` monochrome pixel renderer for the playfield grid, snake, retro diamond food, and eat/collision flash feedback.
- `tests/test_phase2_rendering.gd` through `tests/test_phase7_audio.gd`: Headless automated verification across rendering, movement, gameplay, scoring, UI/navigation, and audio/polish.

---

## 7. Troubleshooting

- **`godot` command not found:** Ensure the folder containing `Godot_v4.x_win64.exe` (or `Godot_v4.x_win64_console.exe`) is in your system `PATH`.
- **Android export fails with Java version error:** Verify `JAVA_HOME` points to **JDK 17**, not Java 8 JRE.
- **`adb` device not detected:** Enable **USB Debugging** on the Android device and verify `platform-tools` is installed and on `PATH`.
