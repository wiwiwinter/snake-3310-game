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

*(To be updated as gameplay logic and automated tests are added in Phases 2–8.)*

- Manual testing in Godot desktop runner (portrait viewport emulation) and on physical Android devices via `adb`.
- Automated GDScript tests located in `tests/`.

---

## 5. Exporting Android Builds

*(Detailed export steps, debug APK generation, and signed release AAB configuration will be documented in Phase 9.)*

**Security Rule:** Never commit `.keystore`, `.jks`, signing passwords, or `export_presets.cfg` containing secrets to Git.

---

## 6. Project Architecture & File Responsibilities

*(Will be populated as modules are created in Phases 1–7.)*

- `scenes/` — Godot scene files (`.tscn`) separated by domain (`main`, `menu`, `game`, `settings`, `ui`).
- `scripts/core/` — Game state machine, constants, configuration, and shared types.
- `scripts/gameplay/` — Grid model, snake logic, food spawning, collision detection.
- `scripts/managers/` — Score/high-score persistence, audio manager, settings manager.
- `scripts/ui/` — HUD, menus, touch controls, and swipe gesture handling.
- `scripts/utilities/` — Pure helper utilities.
- `tests/` — Automated tests for core gameplay and persistence logic.

---

## 7. Troubleshooting

- **`godot` command not found:** Ensure the folder containing `Godot_v4.x_win64.exe` (or `Godot_v4.x_win64_console.exe`) is in your system `PATH`.
- **Android export fails with Java version error:** Verify `JAVA_HOME` points to **JDK 17**, not Java 8 JRE.
- **`adb` device not detected:** Enable **USB Debugging** on the Android device and verify `platform-tools` is installed and on `PATH`.
