# AGENTS.md — CGPA Calculator

Instructions for AI agents working on this codebase.

## Project Overview
CGPA Calculator is a Flutter mobile app (primarily Android) that converts CGPA to percentage for 12 Indian universities. It uses Provider for state management, SharedPreferences for persistence, and Google AdMob for monetization.

## Critical Rules

### Secrets & Security
- **NEVER hardcode** API keys, passwords, or secrets in source files
- AdMob IDs are injected via `--dart-define` at build time; defaults are Google's test IDs
- Keystore passwords come from GitHub Secrets → key.properties (generated in CI)
- The AndroidManifest uses `${admob_app_id}` manifest placeholder — do NOT hardcode AdMob app IDs

### Architecture Patterns
- Use `Provider` (ChangeNotifier) for state management — do not introduce other state solutions
- Use `SharedPreferences` for local persistence — no databases
- All navigation uses `Navigator.push`/`pushReplacement` with `MaterialPageRoute`
- Always check `mounted` before using `context` after async operations
- Always `await` calls to `saveToHistory()` and other persistence methods
- Wrap all file I/O and network operations in try/catch blocks

### UI/UX Standards
- Use `Theme.of(context)` colors instead of hardcoded `Colors.white`, `Colors.grey`, etc.
- Use constants from `lib/utils/constants.dart` (`AppConstants.primaryColor`, etc.)
- Always use `GoogleFonts.poppins()` for headings, `GoogleFonts.inter()` for body text
- Add `tooltip` to every `IconButton`
- Add confirmation dialogs before destructive actions (delete, clear)
- Show loading indicators for async operations (share, export, etc.)
- Test all screens in both light and dark mode

### AdMob
- Ad unit IDs come from `lib/utils/ad_constants.dart` (reads from dart-define)
- `AdService` is a singleton — use `AdService()` to access
- Banner ad is persistent via `PersistentBannerAd` widget in app-level Scaffold
- Interstitial ads show every 2nd calculation (90s cooldown)
- Rewarded ads show every 4th calculation

### Build & Deploy
- Play Store requires AAB (Android App Bundle), not APK
- ProGuard/R8 must be enabled for release builds
- All 11 GitHub Secrets must be properly configured (see CLAUDE.md)
- Key alias is always "mykey"

### Code Style
- Use `super.key` instead of `{Key? key} : super(key: key)`
- Use `Color.withValues(alpha: x)` instead of deprecated `Color.withOpacity(x)`
- Remove `debugPrint` and `print` statements before committing
- Clean up unused imports and dead code

## File Modification Guide
| To change... | Edit... |
|---|---|
| University list/formulas | `lib/data/universities.dart` |
| Color scheme | `lib/utils/constants.dart` + `lib/app.dart` |
| Ad behavior | `lib/services/ad_service.dart` |
| Ad unit IDs | via `--dart-define` (not source code) |
| Build config | `android/app/build.gradle.kts` |
| Permissions | `android/app/src/main/AndroidManifest.xml` |
| CI/CD pipeline | `.github/workflows/ci.yml` (lints/tests/debug) + `.github/workflows/release.yml` (signed AAB/APK) |

## Common Tasks

### Adding a new university
1. Add entry to `universitiesData` list in `lib/data/universities.dart`
2. Provide: id, name, shortName, state, gradingScale, formulaDescription, calculatePercentage function
3. Optional: add `calculateCgpaFromPercentageLogic` to enable the `% → CGPA` reverse converter

### Adding a new screen
1. Create file in `lib/screens/`
2. Add navigation from the appropriate source screen
3. Ensure dark mode compatibility using `Theme.of(context)`
4. Add `PopScope` for back button handling if the screen has unsaved state
