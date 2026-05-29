# Ứng dụng Chấm Công (Android) — Nhân viên

App Flutter nội bộ cho **nhân viên** (role `employee`): đăng ký, đăng nhập, chấm công GPS, xem giờ làm cá nhân. Kết nối REST API backend Node.js + Express.

## Yêu cầu

- Flutter SDK 3.5+
- Android Studio / SDK
- Backend chạy tại cổng **5000** (mặc định)

## Cài đặt

```bash
cd salarycalculate-android
flutter pub get
flutter run
```

## Đổi Base URL

Mở `lib/core/config/app_config.dart`:

```dart
/// true = Android Emulator, false = điện thoại thật
static const bool useEmulator = true;

static const String emulatorBaseUrl = 'http://10.0.2.2:5000';
static const String deviceBaseUrl = 'http://192.168.1.100:5000'; // IP máy tính
```

| Môi trường | Cấu hình |
|------------|----------|
| **Android Emulator** | `useEmulator = true` → `http://10.0.2.2:5000` |
| **Điện thoại thật** | `useEmulator = false` → đổi `deviceBaseUrl` = IP máy chạy backend (cùng WiFi) |

Ví dụ IP máy: `ipconfig` (Windows) → IPv4, ví dụ `192.168.1.50` → `http://192.168.1.50:5000`

> Điện thoại thật cần backend lắng nghe `0.0.0.0`, không chỉ `localhost`.

## Chạy app

```bash
# Emulator
flutter run

# Thiết bị thật (bật USB debugging)
flutter devices
flutter run -d <device-id>
```

## Build APK release

```bash
flutter build apk --release
```

File APK: `build/app/outputs/flutter-apk/app-release.apk`

Ký release (production): tạo keystore và cấu hình `android/app/build.gradle` theo [tài liệu Flutter](https://docs.flutter.dev/deployment/android).

## Cấu trúc chính

```
lib/
  core/          # config, dio, storage, utils
  models/
  services/      # gọi API
  providers/     # state (Provider)
  screens/
  widgets/
```

## API sử dụng

- `POST /api/auth/register`, `login`
- `GET /api/auth/me`
- `GET /api/employees/me`
- `POST /api/attendance/check-in`, `check-out`
- `GET /api/attendance/me/today`, `summary`, `history`

Token JWT lưu bằng `flutter_secure_storage`, tự gắn header `Authorization: Bearer`.

## Quyền Android

- Internet
- Vị trí (GPS) khi chấm công

## Lưu ý

- Chỉ role **employee** được vào app.
- Tài khoản **pending** chưa chấm công được.
- Không dùng Firebase / MongoDB trực tiếp trong app MVP.
