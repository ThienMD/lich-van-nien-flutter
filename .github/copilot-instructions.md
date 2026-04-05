# Copilot Instructions — Lịch Vạn Niên Flutter

## Project Summary

A multi-platform Vietnamese lunar calendar app (Android, iOS, Web, macOS) built with Flutter. Features:
- Daily view (`Ngày`): solar/lunar date, can-chi, zodiac, events, fortune quotes.
- Monthly view (`Tháng`): custom calendar grid.
- Tử vi tab (`Tử vi`): AI horoscope chat via DeepSeek SSE streaming — requires `DEEPSEEK_API_KEY` dart-define.
- Info tab (`Thông tin`): theme toggle, app info.

**Package name**: `calendar` (pubspec `name: calendar`, import prefix `package:calendar/...`)

---

## Runtime & Toolchain

| Tool | Version |
|------|---------|
| Flutter | 3.41.6 (stable) |
| Dart SDK | ≥3.4.0 <4.0.0 |
| Xcode | 15.x+ |
| CocoaPods | **Not used** — migrated to Swift Package Manager |

---

## Key Dependencies

```yaml
dependencies:
  http: ^1.4.0
  package_info_plus: ^9.0.1    # SPM-compatible (v8.1.1+)
  flutter_markdown_plus: ^1.0.7
  cupertino_icons: ^1.0.8
dev:
  flutter_lints: ^5.0.0
```

---

## Build & Validate

### Always run before building
```bash
flutter pub get
```

### Analyze + Test (run after every change)
```bash
flutter analyze && flutter test
```
Expected output: `No issues found!` + `+4: All tests passed!`

### Run (Web — most common during development)
```bash
flutter run -d chrome --dart-define-from-file=.env
```
Copy `.env.example` → `.env` and fill in `DEEPSEEK_API_KEY` first.

### Build Web
```bash
flutter build web --release --base-href /<repo-name>/
```

### Build macOS (uses Swift Package Manager)
```bash
flutter build macos
```
Expected: `✓ Built build/macos/Build/Products/Release/lich_van_nien_flutter.app`

### Build iOS
```bash
flutter build ios --no-codesign
```

---

## Lint Rules (`analysis_options.yaml`)

```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    - unnecessary_new
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - use_key_in_widget_constructors
    - avoid_print
```

- `lib/utils/lunar_solar_utils.dart` is exempt: it has a `// ignore_for_file:` comment for ported astronomical algorithm identifiers.
- Always run `flutter analyze` to zero issues before finishing a task.

---

## File Naming Convention

All Dart source files use **snake_case** (e.g. `single_day_container.dart`, `data_service.dart`). Do not create PascalCase filenames.

---

## Project Layout

```
lib/
  main.dart                          # App entry, state root, navigation scaffold
  components/
    select_date_button.dart          # Date picker trigger widget
    stroke_text.dart                 # Text with stroke outline
    swipe_detector.dart              # Gesture wrapper
    bottom_tabs/                     # BottomTab, TabItem, TabItemData
    calendar/                        # Custom monthly calendar widget
    event/                           # EventItem, EventList widgets
  container/
    single_day_container.dart        # Day view — MAIN tab, zodiac tiles, quote card
    month_container.dart             # Month calendar tab
    horoscope_container.dart         # Tử vi AI chat — SSE streaming
    info_container.dart              # Info/settings tab
    convert_container.dart           # Date conversion utility view
  model/
    event_vo.dart                    # Event data model
    quote_vo.dart                    # Fortune quote model
    horoscope_prompt_vo.dart         # Chat message model (role + content)
  services/
    data_service.dart                # Loads events.json and quotes.json
    deep_seek_service.dart           # DeepSeek SSE streaming (20s connect / 45s read timeout)
  utils/
    date_utils.dart                  # Solar/lunar formatting helpers
    lunar_solar_utils.dart           # Astronomical calculation (ported algorithm, ignore_for_file)
assets/
  events.json                        # Vietnamese calendar events
  quotes.json                        # Fortune quotes
  image_1.jpg … image_16.jpg         # Background images
test/
  widget_test.dart                   # 4 widget tests — checks Icons.calendar_today_rounded
android/   ios/   macos/   web/      # Platform projects
```

---

## Architecture Notes

### State Management
- `_MyHomePageState` in `main.dart` owns shared state:
  - `_selectedDate: DateTime` — current day view date
  - `_birthDate: DateTime?` — user's birth date, shared between `SingleDayContainer` and `HoroscopeContainer`
- Pass `birthDate` and `onBirthDateChanged` as props — do NOT add local birth date state to containers.

### Navigation
- Mobile: `NavigationBar` at bottom (4 destinations).
- Desktop (width ≥ 900): `NavigationRail` on the right.
- Tab icons: `today` / `calendar_month` / `nights_stay` / `info_rounded`.

### Streaming (Tử vi tab)
- `deep_seek_service.dart` streams SSE chunks; `HoroscopeContainer` appends to `_messages`.
- `TweenAnimationBuilder` key is `'${message.role.name}-$index'` — **never include `message.content`** in the key or the UI flashes on every chunk.

### ZodiacAnimal Enum
- Defined in `single_day_container.dart` as `enum ZodiacAnimal` (English names) + `ZodiacAnimalDisplay` extension.
- `_zodiacAnimalFromText` resolves via `CHI.indexOf()` — no Vietnamese string switch.

---

## Swift Package Manager (SPM) — iOS & macOS

CocoaPods has been fully removed. SPM is enabled globally:
```bash
flutter config --enable-swift-package-manager  # already done
```

`ios/Podfile` and `macos/Podfile` have been **deleted**. Do not recreate them.

`ios/Flutter/Debug.xcconfig` and `Release.xcconfig` only contain `#include "Generated.xcconfig"`.
`macos/Flutter/Flutter-Debug.xcconfig` and `Flutter-Release.xcconfig` only contain `#include "ephemeral/Flutter-Generated.xcconfig"`. Do not add `#include "Pods/..."` lines.

---

## Validation Checklist

Before marking a task complete, run:
```bash
flutter analyze && flutter test && flutter build macos
```

There are no GitHub Actions workflows. Validation is manual.

Trust these instructions. Only search the codebase if specific details are not covered here.

