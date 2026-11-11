# Báo cáo và minh chứng

## Đối chiếu yêu cầu

| Yêu cầu | Hiện thực |
|---|---|
| Flutter Web, thêm và hiển thị | Form sản phẩm, lưới thích ứng; Realtime Database |
| name, price, soluong, image | Product.toJson và Rules giới hạn đúng bốn trường |
| Đăng nhập, sửa, xóa | Firebase Authentication; cập nhật node; xác nhận xóa |
| Nâng cao | tìm kiếm, sắp xếp, lọc sắp hết, thống kê, sao chép JSON |
| Ảnh trên điện thoại | image_picker: thư viện/camera; hiển thị bằng Image.memory |
| File CSDL | database/products.json |

## Chụp bằng chứng sau khi kết nối Firebase của bạn

- [ ] Firebase Console → Realtime Database → Data → mở một node sản phẩm. Ảnh phải thấy `name`, `price`, `soluong`, `image`, có thể thu gọn chuỗi ảnh dài.
- [ ] Authentication → Users: có tài khoản admin (ẩn email nếu cần).
- [ ] Web: đăng nhập thành công; danh sách có hình và đủ thông tin.
- [ ] Thêm sản phẩm: chọn JPEG/PNG, tên, giá, số lượng. Thấy node mới trong Firebase.
- [ ] Sửa giá/số lượng; kiểm tra Firebase và ứng dụng ở tab khác cập nhật.
- [ ] Hủy xóa vẫn giữ dữ liệu; xác nhận xóa làm node biến mất.
- [ ] Thử giá âm, số lượng thập phân, thiếu ảnh: app từ chối.
- [ ] Thử tài khoản UID khác: không thể đọc/ghi.
- [ ] Điện thoại: chọn ảnh/chụp ảnh, lưu và hiển thị sản phẩm, thấy cùng dữ liệu trên web.
- [ ] Xuất JSON thực tế từ Console, kiểm tra mỗi node sản phẩm chỉ có bốn trường.

Chưa có thông tin dự án Firebase hoặc thiết bị thật trong phiên phát triển. Vì vậy không đính kèm ảnh Console giả, và không khẳng định đã kiểm thử tích hợp Firebase thật/thiết bị di động. Điền kết quả thực tế sau khi thực hiện checklist.
