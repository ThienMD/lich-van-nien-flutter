# Lịch vạn niên Flutter

Ứng dụng lịch âm dương đa nền tảng (Android, iOS, Web, macOS) được xây dựng bằng Flutter.

## Main features
- Xem lịch theo ngày (`Ngày`)
- Xem lịch theo tháng (`Tháng`)
- Trợ lý `Tử vi` với DeepSeek (chat Markdown + chọn `Ngày sinh`)

## Run locally

### Web

```bash
flutter run -d chrome
flutter build web --release
```

### DeepSeek setup

1. Copy file env mẫu:

```bash
cp .env.example .env
```

2. Điền DeepSeek key vào `.env`.

3. Chạy app với env file:

```bash
flutter run -d chrome --dart-define-from-file=.env
```

### DeepSeek streaming note
- App đã hỗ trợ streaming phản hồi để cải thiện UX trong tab `Tử vi`.
- Trên GitHub Pages public, nên để `Preview mode` để tránh lộ API key.

### Desktop (macOS)

```bash
flutter run -d macOS
flutter build macos
```

## Deploy to GitHub Pages (replace Heroku)

### Static-safe mode (recommended for public site)
Vì GitHub Pages là static hosting, không nên nhúng `DEEPSEEK_API_KEY` vào web build public.

1. Build web với base href của repository:

```bash
flutter build web --release --base-href /<repo-name>/
```

2. Publish thư mục `build/web` lên GitHub Pages (branch `gh-pages` hoặc GitHub Actions).

3. Bật Pages trong repository settings và chọn source phù hợp.

4. URL dạng:

```text
https://<username>.github.io/<repo-name>/
```

### Nếu cần DeepSeek thật trên production
- Dùng backend/proxy riêng để giữ API key ở server.
- GitHub Pages chỉ serve UI, gọi proxy thay vì gọi DeepSeek trực tiếp từ browser.

# Screenshots
<p align="center">
  <img src="img/intro.gif" width="350" title="hover text">
</p>
