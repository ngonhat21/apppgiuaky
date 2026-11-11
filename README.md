# Ứng dụng quản lý sản phẩm — Flutter / Firebase

Phân hệ admin chạy trên web, Android, iOS. Dùng **Firebase Realtime Database** và Firebase Authentication (email/mật khẩu). Chọn một CSDL Firebase trong các lựa chọn của đề, không cần MongoDB.

## Chức năng

- Đăng nhập, ẩn/hiện mật khẩu, đăng xuất; Firebase Rules chỉ cho UID admin đọc/ghi.
- Thêm, hiển thị ảnh/tên/giá/số lượng, sửa và xóa có xác nhận; cập nhật thời gian thực.
- Chọn ảnh trên web/di động, chụp ảnh trên Android/iOS; giới hạn 700 KB sau xử lý.
- Tìm kiếm tên, sắp xếp tên/giá/số lượng, lọc tồn kho ≤ 5, thống kê tồn kho.
- Sao chép toàn bộ dữ liệu JSON để lưu thành file nộp bài.
- Giao diện thích ứng kích thước màn hình, trạng thái chờ/lỗi/rỗng, kiểm tra đầu vào.

## Cấu trúc CSDL — chính xác bốn trường

```
products
  sp001 (khóa Firebase, KHÔNG phải trường dữ liệu)
    name: "Áo thun cotton"
    price: 159000
    soluong: 24
    image: "data:image/png;base64,..."
```

Không lưu `id`, `createdAt`, `category`, `uid` hoặc trường khác trong sản phẩm. ID chỉ là khóa node của Firebase; đối tượng Dart có ID để xác định node cần sửa/xóa, `toJson()` chỉ ghi bốn trường. Tài khoản được lưu riêng trong Firebase Authentication. Ảnh được lưu trong `image` dưới dạng data URI (hoặc URL HTTPS có sẵn trong dữ liệu nhập), không cần Firebase Storage. Ảnh mẫu là PNG màu đơn sắc thật, có thể thay bằng ảnh chụp trong ứng dụng.

**File CSDL bắt buộc:** `database/products.json` (đầy đủ ảnh base64, nhập được trực tiếp). Giá là số VNĐ, số lượng là số nguyên không âm.

## Cài đặt Firebase và chạy web

1. Cài Flutter stable, chạy `flutter doctor`, `flutter pub get`.
2. Tạo dự án tại https://console.firebase.google.com và đăng ký ứng dụng Web.
3. Authentication → Sign-in method → bật Email/Password. Users → Add user để tạo tài khoản admin. Sao chép **UID** (không phải email).
4. Tạo **Realtime Database**, chọn locked mode. Vào Rules, dán nội dung `database/database.rules.json`, thay cả hai chuỗi `REPLACE_WITH_ADMIN_UID` bằng UID admin rồi Publish. Không mở quyền public.
5. Tại tab Data, chọn node gốc `/` → Import JSON → chọn `database/products.json`. Nhập tại gốc để tránh `products/products`. Thao tác import ghi đè dữ liệu tại vị trí chọn; dùng database mới cho bài này.
6. Sao chép `firebase.config.example.json` thành `firebase.config.json`. Điền thông tin từ Project settings → Your apps → Web SDK config, và URL thực tế của Realtime Database. Không dùng URL Cloud Firestore.
7. Authentication → Settings → Authorized domains: thêm `localhost` và tên miền hosting thực tế nếu chưa có.
8. Chạy:

```bash
flutter run -d chrome --dart-define-from-file=firebase.config.json
```

Đăng nhập bằng tài khoản vừa tạo, thử thêm ảnh, sửa giá, xóa một sản phẩm. Tài khoản khác sẽ bị Rules từ chối. Không có tài khoản/mật khẩu mặc định và không tự đăng ký tài khoản trong app.

Nếu không truyền cấu hình, app hiển thị trang hướng dẫn kết nối; đây không phải phiên CRUD kết nối Firebase.

## Android / iOS

```bash
flutter run -d <device-id> --dart-define-from-file=firebase.android.config.json
flutter build apk --dart-define-from-file=firebase.android.config.json
```

Đăng ký ứng dụng Android với package `com.example.apppgiuaky`, dùng Firebase App ID của Android trong bản sao cấu hình `firebase.android.config.json`. Các giá trị project/API key/database URL thuộc cùng dự án. Với iOS đăng ký bundle `com.example.apppgiuaky`, dùng App ID iOS trong `firebase.ios.config.json`, chạy bằng macOS/Xcode. Không dùng App ID Web cho bản di động. Ứng dụng sử dụng `FirebaseOptions` truyền trực tiếp; không chứa service account hay khóa quản trị.

Android đã có quyền INTERNET cho bản release. iOS có mô tả quyền thư viện ảnh/camera. Web chọn tệp ảnh; chụp camera cung cấp trên thiết bị Android/iOS. Chỉ nhận JPEG/PNG/WebP; HEIC cần chuyển JPEG trước. Quyền và camera cần thử trên thiết bị thực.

## Kiểm tra và build

```bash
flutter analyze
flutter test
flutter build web --dart-define-from-file=firebase.config.json
```

Thư viện: `firebase_core`, `firebase_auth`, `firebase_database`, `image_picker`, `intl`; phiên bản chính xác trong `pubspec.yaml` / `pubspec.lock`.

## Nộp bài

1. Nộp mã nguồn repository https://github.com/ngonhat21/apppgiuaky (đưa các file dự án này lên repository của bạn).
2. Nộp `database/products.json`. Sau thao tác thực tế, có thể dùng Firebase Data → Export JSON để lấy CSDL mới nhất; hoặc bấm **Sao chép JSON** trong app, dán vào file UTF-8 `products.json`.
3. Chụp **ảnh CSDL thật** trong Firebase Console: mở `products/sp001` để thấy đủ bốn trường; xem checklist `docs/BAO_CAO.md`. Không dùng ảnh minh họa thay bằng chứng CSDL thật.
4. Nộp ảnh đăng nhập, danh sách, thêm/sửa/xóa trên web, và chọn/chụp ảnh trên điện thoại; ghi phiên bản thư viện theo pubspec.

## Mã nguồn GitHub

Repository: https://github.com/ngonhat21/apppgiuaky

File CSDL bắt buộc nằm tại `database/products.json`. Cấu hình mẫu tại `firebase.config.example.json`; xem các bước thiết lập Firebase ở trên. Không đưa cấu hình riêng, service account hoặc mật khẩu lên GitHub.

## Kết quả kiểm tra trong môi trường phát triển

- `flutter analyze`: không có vấn đề.
- `flutter test`: 3 bài kiểm tra đạt.
- `flutter build web --no-web-resources-cdn --no-wasm-dry-run`: thành công; tài nguyên CanvasKit phục vụ từ cùng host.
- Firebase Realtime Database Emulator: 11 kiểm tra quyền admin và schema đạt, bao gồm đọc/ghi bị chặn với người khác/khách, từ chối trường dư, thiếu trường, giá âm, số lượng thập phân, và CRUD admin.
- Chromium: kiểm tra trang hướng dẫn cấu hình ở kích thước desktop/điện thoại. Ảnh mobile-web là viewport trình duyệt, không phải bằng chứng chạy native.
- Chưa kiểm tra Firebase production, camera điện thoại hoặc build APK/iOS; cần cấu hình dự án và SDK/thiết bị tương ứng.

Chạy lại kiểm tra Rules với một emulator cục bộ đang lắng nghe port 9000:

```bash
npm install --prefix ../work/npm @firebase/util
NODE_PATH=../work/npm/node_modules node tool/rules_test.cjs
```

Script chỉ kết nối loopback và nạp rules với UID test vào emulator; không gọi CSDL production. Có thể khởi động emulator bằng Firebase CLI (`firebase emulators:start --only database --project demo-apppgiuaky`).
