# Lịch Vạn Niên

> A multi-platform Vietnamese lunar calendar built with Flutter — Android, iOS, Web, and macOS.

<p align="center">
  <img src="img/intro.gif" width="360" alt="App preview" />
</p>

---

## Features

| Tab | Description |
|-----|-------------|
| **Ngày** | Daily view — solar & lunar date, can-chi, zodiac animal, events, and fortune quote |
| **Tháng** | Monthly calendar grid with lunar date overlay |
| **Tử vi** | AI horoscope chat powered by DeepSeek with real-time streaming |
| **Thông tin** | Theme switcher (glass / light) and app info |

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | 3.41.6 (stable) |
| Dart SDK | ≥ 3.4.0 |
| Xcode | 15+ (iOS & macOS) |
| Android Studio / SDK | API 21+ |

---

## Getting Started

### 1. Clone & install dependencies

```bash
git clone https://github.com/<username>/<repo-name>.git
cd <repo-name>
flutter pub get
```

### 2. Configure the DeepSeek API key

The **Tử vi** tab requires a [DeepSeek](https://platform.deepseek.com/) API key.

```bash
cp .env.example .env
# Then open .env and fill in your key:
#   DEEPSEEK_API_KEY=sk-...
```

> Without the key the app still runs — the Tử vi tab will show an error when queried.

---

## Running the App

### Web

```bash
flutter run -d chrome --dart-define-from-file=.env
```

### Android

```bash
flutter run -d <android-device-id> --dart-define-from-file=.env
# List connected devices with: flutter devices
```

### iOS (requires macOS + Xcode)

```bash
flutter run -d <ios-device-id> --dart-define-from-file=.env
```

### macOS

```bash
flutter run -d macos --dart-define-from-file=.env
```

---

## Building for Production

### Web

```bash
flutter build web --release --base-href /<repo-name>/
# Output: build/web/
```

### Android (APK)

```bash
flutter build apk --release --dart-define-from-file=.env
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle — recommended for Play Store)

```bash
flutter build appbundle --release --dart-define-from-file=.env
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release --dart-define-from-file=.env
# Requires a valid Apple Developer signing certificate.
# Open ios/Runner.xcworkspace in Xcode to archive and distribute.
```

### macOS

```bash
flutter build macos --dart-define-from-file=.env
# Output: build/macos/Build/Products/Release/lich_van_nien_flutter.app
```

---

## Deploying to GitHub Pages

Deployment is automated via GitHub Actions on every push to `main`.

### One-time setup

1. **Add repository secrets** — go to **Settings → Secrets and variables → Actions** and add:

   | Secret name | Value |
   |-------------|-------|
   | `DEEPSEEK_API_KEY` | Your DeepSeek API key |
   | `DEEPSEEK_API_URL` | `https://api.deepseek.com/chat/completions` |

2. **Enable GitHub Pages** — go to **Settings → Pages**, set Source to **GitHub Actions**.

3. Push to `main` — the workflow at `.github/workflows/deploy.yml` will:
   - Run `flutter analyze` and `flutter test`
   - Build the web app with `--base-href /lich-van-nien-flutter/`
   - Deploy to `https://thienmd.github.io/lich-van-nien-flutter/`

### Manual build (local)

```bash
flutter build web --release \
  --base-href /lich-van-nien-flutter/ \
  --dart-define=DEEPSEEK_API_KEY=<your-key> \
  --dart-define=DEEPSEEK_API_URL=https://api.deepseek.com/chat/completions
```

> **Security note**: The API key is embedded at compile time in the web build. For a fully public site, route DeepSeek calls through a backend proxy instead.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, navigation, shared state
├── components/                  # Reusable UI widgets
├── container/                   # Tab-level screens
│   ├── single_day_container.dart
│   ├── month_container.dart
│   ├── horoscope_container.dart
│   └── info_container.dart
├── model/                       # Data models
├── services/                    # DataService, DeepSeekService (SSE streaming)
└── utils/                       # Date helpers, lunar/solar calculation
assets/
├── events.json                  # Vietnamese calendar events
└── quotes.json                  # Fortune quotes
```

---

## Tech Stack

- **Flutter 3.41.6** — UI framework
- **DeepSeek API** — AI horoscope (SSE streaming)
- **Swift Package Manager** — native dependency management (iOS & macOS, CocoaPods-free)
- [`http`](https://pub.dev/packages/http) · [`package_info_plus`](https://pub.dev/packages/package_info_plus) · [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus)
