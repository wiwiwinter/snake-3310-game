# Google Play Store Listing & Submission Guide (Snake 3310)

## 1. App Identity
- **App Name:** Snake 3310
- **Suggested Package ID:** `com.wiwiwinter.snake3310`
- **Version Name:** `1.0.0` (`versionCode: 1`)
- **Category:** Games > Arcade
- **Pricing:** Free (Offline, No Ads, No In-App Purchases)

## 2. Store Copy

### Short Description (<= 80 characters)
Classic monochrome green LCD Snake game with touch controls and offline play.

### Full Description
Relive the crisp, focused feel of classic monochrome handheld Snake on modern Android phones.

Snake 3310 delivers pure grid-based arcade gameplay inside a retro green LCD frame with responsive controls built for one-handed or two-handed mobile play.

Features:
- Classic 16x20 grid-based Snake gameplay with input buffering to prevent accidental 180-degree turns
- Two wall modes: Solid Walls for classic challenge or Wraparound for endless runs
- Three speed levels: Easy, Normal, and Hard
- Responsive on-screen Game Boy-style D-pad plus swipe gesture controls
- Original retro piezo sound effects and optional chiptune background music with independent toggles
- Local high-score tracking overall and per difficulty
- 100% offline with zero ads, zero tracking, and no account required

## 3. Required Visual Assets (Google Play Console)
- **App Icon:** `512 x 512` PNG (32-bit, generated from `assets/sprites/app_icon.svg`).
- **Feature Graphic:** `1024 x 500` PNG/JPG (no copyrighted phone brand logos).
- **Phone Screenshots:** Minimum 2 portrait screenshots (`1080 x 1920` or `1080 x 2400`) showing:
  1. Main Menu
  2. Active Gameplay (LCD board + centered D-pad)
  3. Settings / High Scores screen
  4. Game Over screen

## 4. Data Safety & Privacy Summary
- **Does your app collect or share any of the required user data types?** No.
- **Offline Storage:** High scores and user preferences (`difficulty`, `wrap_walls`, `sfx_enabled`, `music_enabled`) are stored strictly locally on the device (`user://snake3310_save.cfg`).
- **Permissions:** No sensitive Android permissions (no internet, location, camera, contacts, or external storage access).
- **Privacy Policy:** Host `android/PRIVACY_POLICY.md` at a public HTTPS URL (for example via GitHub Pages) and paste that URL in Google Play Console > App content > Privacy policy.

## 5. Signing & Release Checklist
1. **Generate a private upload keystore outside this Git repository:**
   ```powershell
   & "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v -keystore "$env:USERPROFILE\.android\snake3310-release.keystore" -alias snake3310 -keyalg RSA -keysize 2048 -validity 10000
   ```
   Back up this keystore and its passwords securely; losing it prevents updating the app on Google Play unless you use Play App Signing key reset.
2. **Never commit** `.keystore`, `.jks`, passwords, or `export_presets.cfg` (already excluded by `.gitignore`).
3. **Export signed AAB** (`android/build/snake3310-release.aab`) targeting Android API 35 (or current Google Play required Target API Level).
4. **Verify APK locally** on a physical Android phone (`adb install android/build/snake3310-debug.apk`).
5. **Upload AAB** to Google Play Console > Testing > Internal testing (or Closed testing for personal developer accounts) before promoting to Production.
