# Snake 3310

A lightweight, offline-first Android mobile game inspired by the classic Nokia 3310 Snake, built with **Godot 4.x** and **GDScript**.

## Project Status

- **Current Phase:** Phase 2 Complete — Next: Phase 3 (Snake Movement)
- **Version:** `0.1.0` (Phase 2: Core Game Rendering Complete)

## Planned Features

- **Classic Grid-Based Gameplay:** Continuous four-directional snake movement, random valid food spawning, snake growth, self-collision, and configurable wall behavior (solid walls or wraparound).
- **Monochrome LCD Aesthetic:** Retro pixel-based visuals inspired by classic green monochrome LCD screens (`#9BBC0F`, `#8BAC0F`, `#306230`, `#0F380F`) using original, non-infringing assets.
- **Difficulty Levels:** Easy, Normal, and Hard modes controlling movement speed.
- **Mobile-First Controls:** Responsive on-screen directional buttons, swipe gesture support, input buffering to prevent accidental 180-degree turns, pause/resume, and quick restart.
- **Local Persistence:** Offline gameplay with locally saved high scores and audio/gameplay settings.
- **Screens:** Splash Screen, Main Menu, Game Screen, Pause Screen, Game Over Screen, Settings Screen, and High Score Screen.

## Technology Stack

- **Game Engine:** Godot `4.7.2-stable` (Standard, GL Compatibility)
- **Language:** GDScript
- **Code Editor:** Visual Studio Code (`geequlim.godot-tools` v2.7.1) + Antigravity Chat
- **Android Packaging:** Android SDK Command-Line Tools (`platform-tools`, `build-tools;35.0.1`, `platforms;android-35`) & Eclipse Temurin OpenJDK `17.0.21`
- **Version Control:** Git / GitHub

## Screenshots

*No screenshots yet — screenshots will be added once the game scenes are implemented and verified.*

## Installation & Setup

See [GUIDE.md](GUIDE.md) for environment setup, running the project locally, testing, and Android export instructions.

## Planned Repository Structure

```text
snake-3310/
├── README.md
├── GUIDE.md
├── DEVELOPMENT_PLAN.md
├── REQUIREMENTS.md
├── CHANGELOG.md
├── project.godot          # (Phase 1)
├── scenes/
│   ├── main/
│   ├── menu/
│   ├── game/
│   ├── settings/
│   └── ui/
├── scripts/
│   ├── core/
│   ├── gameplay/
│   ├── managers/
│   ├── ui/
│   └── utilities/
├── assets/
│   ├── sprites/
│   ├── fonts/
│   ├── audio/
│   └── backgrounds/
├── tests/
└── android/
```
