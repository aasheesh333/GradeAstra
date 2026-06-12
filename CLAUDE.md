# CGPA Calculator

Smart CGPA (Cumulative Grade Point Average) Calculator for Indian university students.

## Tech Stack
- **Framework:** Flutter 3.22.0 (Dart SDK >=3.0.0 <4.0.0)
- **State Management:** Provider (^6.1.2)
- **Local Storage:** SharedPreferences
- **Ads:** Google Mobile Ads (AdMob) with banner, interstitial, and rewarded ads
- **Charts:** fl_chart (^0.68.0)
- **Design:** Material 3 (useMaterial3: true)
- **Fonts:** Google Fonts (Poppins, Inter)

## Project Structure
```
lib/
├── main.dart                    # Entry point: AdMob init, Provider setup
├── app.dart                     # MaterialApp with light/dark themes, persistent banner ad
├── data/
│   └── universities.dart        # 12 university definitions with CGPA→% formulas
├── models/
│   ├── university_model.dart    # University data class (name, formula, grading scale)
│   ├── semester_model.dart      # Semester data class (SGPA, credits, date)
│   └── subject_model.dart       # Subject data class (name, credits, grade, grade point)
├── providers/
│   ├── cgpa_provider.dart       # Core state: university selection, calculations, history
│   └── theme_provider.dart      # Dark/light mode toggle with persistence
├── screens/
│   ├── splash_screen.dart       # 2.2s splash with branding
│   ├── home_screen.dart         # Dashboard: 2x2 feature grid + recent calculations
│   ├── converter_screen.dart    # CGPA-to-percentage converter with university selector
│   ├── semester_screen.dart     # Add subjects to calculate SGPA
│   ├── overall_screen.dart      # Multi-semester CGPA tracker with line chart
│   ├── result_screen.dart       # Display results + share as screenshot
│   ├── history_screen.dart      # View/delete/export-PDF of past calculations
│   └── settings_screen.dart     # Default university, dark mode, about, links
├── services/
│   └── ad_service.dart          # Singleton AdMob service: interstitial + rewarded
├── utils/
│   ├── ad_constants.dart        # AdMob unit IDs (from dart-define env vars)
│   ├── cgpa_calculator.dart     # Static utility: validate CGPA, rounding
│   └── constants.dart           # App color palette and URL constants
└── widgets/
    ├── persistent_banner_ad.dart # Persistent banner ad at bottom of app
    ├── subject_tile.dart         # Row widget for subject display
    └── university_selector.dart  # Dropdown selector for universities
```

## Key Architecture Decisions
- **No routing library** — navigation uses direct `Navigator.push` / `MaterialPageRoute`
- **No database** — all persistence via SharedPreferences (JSON strings)
- **AdMob IDs via dart-define** — production IDs injected at build time via `--dart-define`
- **Singleton AdService** — manages interstitial and rewarded ad lifecycle
- **Double Scaffold** — app-level Scaffold (for persistent banner ad) wraps per-screen Scaffolds

## Supported Universities (12)
AKTU, VTU, Mumbai University, Anna University, RGPV, GTU, SPPU, JNTU, KTU, PTU, Delhi University, Generic/Other

## Build & Run
```bash
# Development (uses test ad IDs)
flutter run

# Production build (inject real IDs via secrets)
flutter build appbundle --release \
  --dart-define=ADMOB_APP_ID=your_app_id \
  --dart-define=ADMOB_BANNER_ID=your_banner_id \
  --dart-define=ADMOB_INTERSTITIAL_ID=your_interstitial_id \
  --dart-define=ADMOB_REWARDED_ID=your_rewarded_id \
  --dart-define=PACKAGE_NAME=com.dhanuk.gradeastra \
  --dart-define=VERSION_CODE=1 \
  --dart-define=VERSION_NAME=1.0.0
```

## CI/CD
- GitHub Actions workflow at `.github/workflows/build_apk.yml`
- Secrets: KEYSTORE_BASE64, KEY_ALIAS, KEYSTORE_PASSWORD, KEY_PASSWORD, ADMOB_APP_ID, ADMOB_BANNER_ID, ADMOB_INTERSTITIAL_ID, ADMOB_REWARDED_ID, PACKAGE_NAME, VERSION_CODE, VERSION_NAME
- Builds split-per-ABI APKs, universal APK, and AAB (Android App Bundle)
- Signing: uses key.properties generated from secrets

## Android Configuration
- **Package:** com.dhanuk.gradeastra
- **compileSdk:** 36, **targetSdk:** 34, **minSdk:** Flutter default (21)
- **Signing:** Release keystore via key.properties (generated in CI from secrets)
- **ProGuard/R8:** Enabled for release builds
- **AdMob App ID:** Injected via Gradle manifestPlaceholders from dart-define

## Testing
```bash
flutter test
flutter analyze
```

## Constants
- Primary Color: `Color(0xFF1565C0)` — defined in `AppConstants.primaryColor`
- Accent Color: `Color(0xFFFF6F00)` — defined in `AppConstants.accentColor`
- All color constants in `lib/utils/constants.dart`
- All URL constants in `lib/utils/constants.dart`
