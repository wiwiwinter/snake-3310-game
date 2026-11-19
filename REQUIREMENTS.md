# Requirements Specification — Snake 3310

## 1. Functional Requirements

### 1.1 Core Gameplay
- **FR-01:** The game shall operate on a discrete 2D grid.
- **FR-02:** The snake shall move continuously one grid cell per tick in one of four cardinal directions (Up, Down, Left, Right).
- **FR-03:** Food shall spawn randomly on an unoccupied grid cell (never overlapping the snake's head or body).
- **FR-04:** Consuming food shall increment the snake's length by 1 segment and increase the player's score.
- **FR-05:** Colliding with the snake's own body shall trigger the Game Over state.
- **FR-06:** Wall behavior shall be configurable between **Solid Walls** (collision triggers Game Over) and **Wraparound** (snake emerges on the opposite edge).
- **FR-07:** Players shall be able to pause, resume, and restart a game session.

### 1.2 Controls
- **FR-08:** The game shall support on-screen directional buttons suitable for one-handed or two-handed mobile play.
- **FR-09:** The game shall support touch swipe gestures for changing direction.
- **FR-10:** The input system shall prevent immediate 180-degree reversals and buffer rapid valid turns cleanly so unintended self-collisions do not occur.
- **FR-11:** Keyboard directional keys shall also be supported for desktop development and testing.

### 1.3 Scoring & Difficulty
- **FR-12:** The game shall display the current score during gameplay and reset it on each new game.
- **FR-13:** The game shall persist the highest score locally on the device and display it on the High Score, Menu, and Game Over screens.
- **FR-14:** The game shall provide three difficulty settings — **Easy**, **Normal**, and **Hard** — that adjust the snake's movement speed.

### 1.4 Game States & Screens
- **FR-15:** The game shall implement a structured state flow: `Main Menu`, `Ready`, `Playing`, `Paused`, and `Game Over`.
- **FR-16:** The application shall include the following screens with a unified retro LCD visual style:
  1. Splash Screen
  2. Main Menu
  3. Game Screen
  4. Pause Screen
  5. Game Over Screen
  6. Settings Screen
  7. High Score Screen

### 1.5 Audio & Settings
- **FR-17:** The game shall provide retro-inspired sound effects and optional background music.
- **FR-18:** Players shall be able to toggle sound effects and music independently, with preferences saved locally.

---

## 2. Non-Functional Requirements

- **NFR-01 (Offline-First):** The game shall function 100% offline with no network requirement.
- **NFR-02 (Performance):** The game shall maintain smooth, consistent frame pacing and deterministic grid-step timing on entry-level and modern Android smartphones.
- **NFR-03 (Responsiveness):** UI and playfield layout shall adapt cleanly across common portrait Android screen sizes and aspect ratios (e.g., 16:9, 19.5:9, 20:9).
- **NFR-04 (Visual Identity & IP Safety):** Visuals shall evoke a monochrome green LCD aesthetic (`#9BBC0F`, `#8BAC0F`, `#306230`, `#0F380F`) with high legibility and strictly original assets (no Nokia trademarks, logos, or copyrighted assets).
- **NFR-05 (Maintainability):** Code shall be modular, cleanly separated by responsibility, and follow GDScript best practices.
- **NFR-06 (Privacy & Security):** No personal data collection beyond local on-device game saves; signing keys and credentials must never be committed to version control.

---

## 3. Hardware & Software Requirements

### Development Environment
- **OS:** Windows (current workspace)
- **Engine:** Godot 4.x (Standard)
- **IDE/Editor:** Visual Studio Code + `godot-tools`
- **Build Tools:** OpenJDK 17, Android SDK Command-Line Tools, Godot Export Templates
- **Version Control:** Git

### Target Device (Android)
- **Form Factor:** Android smartphones (portrait orientation)
- **Input:** Touchscreen (tap buttons + swipe gestures)
- **Storage:** Lightweight footprint (< 50 MB target)

---

## 4. Android Compatibility Requirements

- **Packaging:** Debug/test APK and signed Android App Bundle (AAB) for Google Play.
- **Minimum SDK / Target SDK:** To be aligned with Godot 4.x Android export defaults and current Google Play Store Target API Level policy during Phase 9 verification.
- **Lifecycle:** Game must automatically pause when the app loses focus or moves to the background.
