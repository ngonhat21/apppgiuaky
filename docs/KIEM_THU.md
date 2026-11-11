# Kiểm thử đã thực hiện

Ngày 11/11/2026. Flutter stable tại thời điểm thực hiện, xem môi trường chính xác trong flutter-version.txt.

- Phân tích tĩnh: `flutter analyze`, No issues found.
- Unit/widget: 3/3 đạt — file JSON và ảnh PNG, schema và giá trị không hợp lệ, trang cấu hình.
- Firebase Rules bằng Realtime Database Emulator v4.11.2: 11/11 đạt — admin create/read/update/delete; từ chối đọc với UID khác/khách; từ chối ghi với UID khác; từ chối trường dư, thiếu trường, giá âm, số lượng thập phân.
- Build Web release với CanvasKit cục bộ: thành công.
- Chromium headless desktop 1280×850 và mobile viewport 390×844: trang hướng dẫn cấu hình; chưa phải màn hình CRUD đã kết nối Firebase.

Giới hạn: chưa được cung cấp dự án Firebase production. Chưa có ảnh Console CSDL thật, chưa chạy native Android/iOS. Xem BAO_CAO.md để hoàn thành minh chứng nộp bài.
