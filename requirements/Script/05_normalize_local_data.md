# Chuẩn hóa dữ liệu local — 30/09/2026

Đã áp dụng `05_normalize_local_data.sql` trên PostgreSQL local, database `phong_kham2`, container `phongkham_postgres`. Sau khi người dùng kiểm tra local và yêu cầu đồng bộ, đã cập nhật cloud ngày 30/09/2026; xem mục đồng bộ bên dưới.

## Phạm vi và nguồn gốc

Đây vẫn là dữ liệu demo. Tên bệnh nhân và nhân viên được chuẩn hóa thành tên Việt Nam tự nhiên, không phải danh tính đã được xác minh. Đổi nhãn thuốc không xác nhận đơn thuốc hay tính đúng đắn lâm sàng của các hồ sơ demo. Giá, số lượng, lịch sử khám, ngày sinh và các số điện thoại/CCCD đã có không được xác minh lại.

- 360 bệnh nhân Q3/Q5: tên đầy đủ, không còn hậu tố mẫu; bỏ địa chỉ giả lập bằng NULL. Không tạo thêm số điện thoại, CCCD hoặc địa chỉ.
- 8 bệnh nhân gốc: thêm dấu vào tên hiện có. Giữ nguyên bệnh nhân người dùng nhập ngoài các mã này.
- 18 nhân viên: thay tên đánh số/chữ cái bằng tên đầy đủ; bỏ email mẫu và chứng chỉ `DEMO-*` không có nguồn.
- Chuẩn hóa khoa, phòng khám, nhóm bệnh, dịch vụ, thiết bị, nhân công và nội dung khoản mục hóa đơn Q3/Q5.
- Bỏ chuỗi triệu chứng giả lập bằng NULL; giữ ý nghĩa kết luận và ghi chú lương khi bỏ phần nhãn giả lập.
- Giữ mã Q3/Q5 để truy vết nguồn dữ liệu và giữ toàn bộ quan hệ tham chiếu.

## Thuốc đã đối chiếu

| Mã | Tên mới | Hãng | Nguồn chính thức |
| --- | --- | --- | --- |
| Q3T1, Q5T1 | Omeprazol DHG 20 mg | DHG Pharma | https://dhgpharma.com.vn/vi/san-pham/tieu-hoa-gan-mat/omeprazol-dhg |
| Q3T2, Q5T2 | Mebilax 7,5 mg | DHG Pharma | https://dhgpharma.com.vn/vi/san-pham/co-xuong-khop/mebilax-75 |
| Q3T3, Q5T3 | Hapacol 500 mg | DHG Pharma | https://dhgpharma.com.vn/vi/san-pham/giam-dau-ha-sot/hapacol-500-vang-dam-nhat |

Đơn vị cấp phát của 6 mã này vẫn là viên. Đơn giá giữ theo dữ liệu demo, không phải giá thị trường đã xác minh. Các mã Q3/Q5 trùng sản phẩm vẫn giữ tách biệt vì đã có lịch sử sử dụng và tồn kho riêng.

## Thông tin còn cần đối chiếu

- `NA01`: tên “Thuốc trị cúm”, hãng `CUM010001`. Cần tên trên bao bì, hàm lượng và nhà sản xuất để xác định đúng thuốc. Không tự đổi thành sản phẩm khác.
- `TH05`: “Dung dich sat trung” chưa xác định hoạt chất/nồng độ; cần bao bì hoặc nguồn nhập kho.
- Các thuốc gốc TH01–TH04 và thông tin cá nhân/chứng chỉ cũ chưa được xác minh bằng chứng từ. Không thể khẳng định toàn bộ cơ sở dữ liệu là dữ liệu thực chỉ nhờ đổi tên.

## Sao lưu và kiểm tra

Bản sao trước sửa: `.local-backups/before-data-cleanup-20260930.dump` (pg_dump custom format, quyền file 600, được loại khỏi Git qua `.git/info/exclude`).

Đã chạy thử transaction rồi rollback trước khi áp dụng. Script khóa các bảng trong lúc sửa, so sánh toàn bộ bản ghi ngoài các cột văn bản cho phép; phát sinh sai khác thì rollback. Số lượng bản ghi, mã, liên kết, ngày giờ, tồn kho, đơn giá, tiền hóa đơn/lương không đổi. Tổng 1.290 hóa đơn Q3/Q5 khớp chi tiết.

Quét các cột chuỗi của toàn bộ bảng: không còn nhãn `giả lập`, `học tập`, `[Mẫu`, `mẫu Q3/Q5`, `kiểm thử`, `example.invalid`, `DEMO-`. Chạy lại script không thay đổi bất kỳ bản ghi nào. API local trả HTTP 200 và tên mới; frontend localhost:5173 trả HTTP 200.

## Chạy lại sau khi nạp dữ liệu demo

Các file 03/04 được giữ nguyên làm nguồn gốc bộ demo. Sau khi nạp 02/03/04 vào một database local mới, chạy tiếp 05:

```sh
docker exec -i phongkham_postgres psql -X -U postgres -d phong_kham2 -v ON_ERROR_STOP=1 < requirements/Script/05_normalize_local_data.sql
```

Không dùng quy trình này để tự động thay danh tính hoặc thuốc trong hồ sơ người bệnh thực.


## Đồng bộ cloud — 30/09/2026

Đã đồng bộ bản local đã chuẩn hóa vào database `neondb` trên Neon theo yêu cầu người dùng. Giao dịch chạy thử với ROLLBACK thành công trước khi chạy chính thức với COMMIT.

- Thêm 11.930 bản ghi trên các bảng liên quan (bao gồm 360 bệnh nhân Q3/Q5 và 1 bệnh nhân local nhập riêng, 1.290 lượt khám/chữa, 1.290 hóa đơn).
- Cập nhật 17 bản ghi dùng chung: 8 tên bệnh nhân gốc, 6 tên nhân viên và 3 email mẫu.
- Mã `BN009` trên cloud và local thuộc hai người khác nhau. Giữ nguyên `BN009` trên cloud; đưa bệnh nhân local lên với mã `BN010`. Không có lượt khám nào của bệnh nhân local này cần đổi liên kết.
- Giữ nguyên các lượt khám, hóa đơn, sử dụng thuốc và tham số chỉ có trên cloud; giữ trạng thái đã khỏi/ngày kết thúc của DT001, DT002, DT009 và tồn kho TH01 = 480 trên cloud.
- Không xóa bản ghi, thay schema hay triển khai lại mã ứng dụng. Các bảng `neon_auth` không thuộc phạm vi cập nhật.
- Cloud sau đồng bộ: 370 bệnh nhân, 1.308 sự kiện y tế, 1.293 hóa đơn.
- Bản sao đầy đủ trước đồng bộ: `.local-backups/cloud-before-sync-20260930.dump`; đã kiểm tra đọc được danh mục pg_restore. Các tệp snapshot và SQL thực thi nằm trong `.local-backups/`, được loại khỏi Git.
- Giao dịch kiểm tra toàn bộ 25 bảng public trước và sau ghi, dừng nếu dữ liệu cloud khác với bản đã đối chiếu. Không tắt khóa ngoại hoặc trigger. Toàn bộ 1.290 hóa đơn Q3/Q5 khớp tổng chi tiết.

Các giới hạn xác minh ở trên vẫn áp dụng, bao gồm NA01/TH05 và nguồn gốc hồ sơ demo. Đồng bộ không biến dữ liệu demo thành hồ sơ người bệnh đã xác minh.

Kiểm tra sau COMMIT: đọc lại độc lập toàn bộ 25 bảng public, khớp chính xác kết quả đã lập; API cloud `/api/v1/thuoc` trả HTTP 200 với đủ 12 thuốc, trong đó 6 mã Q3/Q5 hiển thị đúng tên mới.
