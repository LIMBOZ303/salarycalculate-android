# Chạy script này lần đầu nếu thiếu thư mục android/ios do clone chỉ có lib/
# Yêu cầu: Flutter đã cài và có trong PATH

Write-Host "Khoi tao project Flutter (neu can)..."
flutter create . --project-name salarycalculate_android --org com.salarycalculate

Write-Host "Tai dependencies..."
flutter pub get

Write-Host "Phan tich code..."
flutter analyze

Write-Host "Xong. Chay app: flutter run"
