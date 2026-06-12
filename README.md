# CGPA Calculator — Smart Grade Tracker

![Build](https://github.com/YOUR_USERNAME/gradeastra/actions/workflows/build_apk.yml/badge.svg)

Smart CGPA to Percentage calculator for 12+ Indian universities. Built with Flutter.

## Supported Universities

AKTU · VTU · Mumbai · Anna · RGPV · GTU · SPPU · JNTU · KTU · PTU · Delhi · Generic

## Features

- CGPA → Percentage (university-specific formulas)
- Semester SGPA calculator
- Overall CGPA tracker with chart
- Calculation history + PDF export
- AdMob monetized
- Offline — no internet required
- Dark mode support

## Build APK

`flutter build apk --release --split-per-abi`

Download from Actions → Artifacts tab.

## Go Live Checklist

- Inject real AdMob IDs via `--dart-define` (banner, interstitial, rewarded, app id)
- Add real signing keystore
- Update Play Store listing
