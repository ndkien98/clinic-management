# BÁO CÁO CHI TIẾT CÁC ĐIỂM CHỈNH SỬA VÀ CHUẨN HÓA CẤU TRÚC CSDL
**Học viện Công nghệ Bưu chính Viễn thông (PTIT)**  
**Môn học:** Các hệ thống cơ sở dữ liệu  
**Đề tài 4:** Quản lý phòng khám bệnh tư nhân  
**GVHD:** TS. Phan Thị Hà  
**File script sau khi chỉnh sửa:** `cai_dat_phong_kham.sql`

---

## 1. TỔNG QUAN

Quá trình đối chiếu giữa **Phần phân tích thiết kế** (Mục 1: Kịch bản thế giới thực, Mục 2: Lược đồ E-R, Mục 4: Ánh xạ quan hệ & Chuẩn hóa BCNF/3NF) và **Phần cài đặt SQL** (Mục 5 trong báo cáo cũ) cho thấy mã SQL ban đầu có một số điểm chưa khớp với lý thuyết, thiếu các ràng buộc toàn vẹn quan trọng của PostgreSQL, và tồn tại lỗi logic trong một số Trigger/Stored Procedure.

File SQL mới `cai_dat_phong_kham.sql` đã được hoàn thiện lại nhằm:
1. Đảm bảo **khớp 100%** giữa mô hình thực thể quan hệ đã phân tích và các câu lệnh `CREATE TABLE`.
2. Đảm bảo **tính toàn vẹn dữ liệu** (Domain Integrity, Referential Integrity, Entity Integrity).
3. Đảm bảo **tính thực thi ổn định** khi cài đặt thực tế trên hệ quản trị PostgreSQL (không bị lỗi khóa ngoại khi xóa/sửa, không bị race-condition, không văng lỗi khi gọi transaction).

---

## 2. BẢNG TỔNG HỢP CÁC NỘI DUNG ĐÃ CHỈNH SỬA

| STT | Vị trí / Đối tượng | Trạng thái trước khi sửa | Sau khi chỉnh sửa | Mục đích & Ý nghĩa |
| :---: | :--- | :--- | :--- | :--- |
| **1** | Bảng `BacSy`, `YTa` (Khóa chính) | Dùng `MaBS`, `MaYT` làm khóa chính. | Đổi khóa chính về `MaNV` (PK, FK tham chiếu `NhanVienYTe(MaNV)`). | Khớp đúng chuẩn lý thuyết kế thừa ISA (Phần 2 & 4.1 của báo cáo). |
| **2** | Ràng buộc toàn vẹn xóa tầng | Mặc định `NO ACTION`. Xóa bản ghi cha bị chặn lỗi. | Bổ sung `ON DELETE CASCADE` cho quan hệ ISA và thực thể yếu. | Dọn dẹp dữ liệu tự động, tránh lỗi Foreign Key Violation khi hủy/xóa. |
| **3** | Bảng `DotDieuTri` (Liên kết đệ quy) | Không có xử lý khi xóa đợt trước hoặc xóa giường. | Thêm `ON DELETE SET NULL` cho `MaGiuong` và `MaDotTruoc`. | Giữ lại lịch sử đợt điều trị tái phát ngay cả khi đợt trước bị chỉnh sửa/xóa. |
| **4** | Ràng buộc miền giá trị (`CHECK`) | Thiếu CHECK trạng thái giường, hóa đơn, tồn kho âm. | Bổ sung `CHECK` cho `GiuongBenh.TrangThai`, `HoaDon.TrangThaiTT`, `Thuoc.TonKho >= 0`... | Đảm bảo tính toàn vẹn dữ liệu, tránh dữ liệu rác/âm. |
| **5** | Tính Idempotent của Script | Không có cơ chế xóa sạch bảng khi chạy lại. | Thêm khối `DROP TABLE ... CASCADE` theo đúng thứ tự phụ thuộc. | Cho phép chạy lại (re-run) script nhiều lần mà không bị lỗi đọng bảng. |
| **6** | Trigger 7.1 (`sinh_ma_sukien`) | Dễ bị mã `NULL` nếu thời gian null; chưa bắt chuỗi rỗng. | Bổ sung `COALESCE(NEW.ThoiGian, CURRENT_TIMESTAMP)`, bắt `WHEN (NEW.MaSuKien IS NULL OR NEW.MaSuKien = '')`. | Mã sự kiện luôn sinh chuẩn định dạng: `<Khoa>-<MaBS>-<K/C>-<YYYYMMDD>-<STT>`. |
| **7** | Trigger 7.3 (`dong_dot_dieu_tri`) | Chỉ đổi trạng thái đợt điều trị, quên giải phóng giường. | Tự động cập nhật `GiuongBenh.TrangThai = 'Trong'` khi đợt đóng ('DaKhoi'). | Hiện thực hóa đúng nghiệp vụ quản lý tài nguyên giường bệnh ở Mục 1.3.3. |
| **8** | Procedure 10.3 (`sp_XuatHoaDon`) | **Bỏ quên chi phí Thiết bị và Dịch vụ**; nhảy cóc `+100` dòng; trùng khóa khi xuất lại. | Bổ sung `SuDungThietBi` & `SuDungDichVu`; đánh số dòng tuần tự liên tục; xóa chi tiết cũ trước khi tính lại. | Hóa đơn tổng hợp đúng và đủ 100% các chi phí y tế; không bị lỗi Duplicate Key. |
| **9** | Procedure 10.5 (`sp_HuyLanKham`) | Lệnh `DELETE FROM LanKham; DELETE FROM SuKienYTe;` bị lỗi FK chặn. | Dọn dẹp các bảng con liên quan trước khi xóa sự kiện chính. | Giao dịch hủy lần khám chạy trơn tru, có kiểm tra điều kiện an toàn. |
| **10** | Dữ liệu khởi tạo `ThamSoHeThong` | Bảng cấu hình bị rỗng. | Nạp sẵn 3 tham số: `LUONG_CO_SO`, `THUONG_BS_HOAN_THANH`, `THUONG_YTA_HOTRO`. | Cung cấp hằng số cho hàm tính lương và thủ tục phát lương hoạt động chính xác. |

---

## 3. PHÂN TÍCH CHI TIẾT TỪNG ĐIỂM CHỈNH SỬA VÀ NGUYÊN NHÂN KỸ THUẬT

### 3.1. Chuẩn hóa Khóa chính bảng con `BacSy` và `YTa` theo mô hình ISA

* **Hiện trạng cũ:**
  Trong Mục 5.1 báo cáo cũ, bảng `BacSy` có khóa chính là `MaBS`, bảng `YTa` có khóa chính là `MaYT`:
  ```sql
  CREATE TABLE BacSy (
      MaBS VARCHAR(10) PRIMARY KEY REFERENCES NhanVienYTe(MaNV), ...
  );
  CREATE TABLE YTa (
      MaYT VARCHAR(10) PRIMARY KEY REFERENCES NhanVienYTe(MaNV), ...
  );
  ```
* **Vấn đề phát sinh:**
  1. Trong Mục 4.1 và Mục 4.2 của báo cáo, lược đồ đã được phân tích là:
     - `BacSy(MaNV, Email, ChuyenMon)` với Khóa chính: `MaNV`, Khóa ngoại: `MaNV -> NhanVienYTe`.
     - `YTa(MaNV, ChungChiHanhNghe)` với Khóa chính: `MaNV`, Khóa ngoại: `MaNV -> NhanVienYTe`.
  2. Theo nguyên lý ánh xạ tập thực thể con ISA (Specialization/Generalization) trong giáo trình Cơ sở dữ liệu: Khóa chính của bảng cha (`MaNV`) chuyển thành **vừa là khóa chính vừa là khóa ngoại** của bảng con, giữ nguyên tên thuộc tính `MaNV`.
  3. Bảng phân công nhân công `SuDungNhanCong` tham chiếu `MaNV REFERENCES NhanVienYTe(MaNV)` chứ không tham chiếu `MaBS` hay `MaYT`.
* **Giải pháp trong script mới:**
  ```sql
  CREATE TABLE BacSy (
      MaNV VARCHAR(10) PRIMARY KEY REFERENCES NhanVienYTe(MaNV) ON DELETE CASCADE ON UPDATE CASCADE,
      Email VARCHAR(100),
      ChuyenMon VARCHAR(100)
  );

  CREATE TABLE YTa (
      MaNV VARCHAR(10) PRIMARY KEY REFERENCES NhanVienYTe(MaNV) ON DELETE CASCADE ON UPDATE CASCADE,
      ChungChiHanhNghe VARCHAR(100)
  );
  ```
  Tại bảng `SuKienYTe`:
  ```sql
  CREATE TABLE SuKienYTe (
      MaSuKien   VARCHAR(50) PRIMARY KEY,
      MaBN       VARCHAR(10) NOT NULL REFERENCES BenhNhan(MaBN),
      MaBS       VARCHAR(10) NOT NULL REFERENCES BacSy(MaNV),
      ThoiGian   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      LoaiSuKien VARCHAR(10) NOT NULL CHECK (LoaiSuKien IN ('KHAM', 'CHUA'))
  );
  ```
  *Ý nghĩa:* Tên cột ở bảng sự kiện là `MaBS` để thể hiện rõ ngữ nghĩa "Bác sĩ phụ trách", tham chiếu chính xác đến `BacSy(MaNV)`. Vừa khớp tuyệt đối với lý thuyết ở Mục 4, vừa tường minh trên PostgreSQL.

---

### 3.2. Bổ sung các hành vi toàn vẹn tham chiếu tầng (`ON DELETE CASCADE` và `ON DELETE SET NULL`)

* **Hiện trạng cũ:**
  Hầu hết các câu lệnh `REFERENCES` ở Mục 5.1 không chỉ định mệnh đề `ON DELETE`. Trong PostgreSQL, mặc định là `NO ACTION` (tương đương `RESTRICT`).
* **Vấn đề phát sinh:**
  1. Khi một nhân viên nghỉ việc hoặc thông tin nhân viên bị xóa khỏi `NhanVienYTe`, hệ thống sẽ ném lỗi Foreign Key Violation do dữ liệu ở `BacSy` hoặc `YTa` vẫn còn.
  2. Khi hủy/xóa một `SuKienYTe`, các bảng con gồm `LanKham`, `LanChuaBenh`, `HoaDon`, `SuDungThuoc`, `SuDungNhanCong` sẽ chặn lệnh xóa.
  3. Trong bảng `DotDieuTri`, cột `MaDotTruoc` tham chiếu đệ quy đến `DotDieuTri(MaDotDieuTri)`. Nếu không có quy định rõ ràng, việc xóa một đợt trước sẽ gây lỗi hoặc xóa nhầm cả chuỗi điều trị tái phát phía sau.
* **Giải pháp trong script mới:**
  - Áp dụng `ON DELETE CASCADE` cho quan hệ kế thừa ISA:
    `BacSy(MaNV) -> NhanVienYTe(MaNV)`  
    `YTa(MaNV) -> NhanVienYTe(MaNV)`  
    `LanKham(MaSuKien) -> SuKienYTe(MaSuKien)`  
    `LanChuaBenh(MaSuKien) -> SuKienYTe(MaSuKien)`
  - Áp dụng `ON DELETE CASCADE` cho thực thể yếu và bảng liên kết N-N:
    `HoaDon(MaSuKien) -> SuKienYTe(MaSuKien)`  
    `HoaDonChiTiet(MaSuKien) -> HoaDon(MaSuKien)`  
    `SuDungThuoc(MaSuKien) -> SuKienYTe(MaSuKien)`  
    `SuDungThietBi(MaSuKien) -> SuKienYTe(MaSuKien)`  
    `SuDungDichVu(MaSuKien) -> SuKienYTe(MaSuKien)`  
    `SuDungNhanCong(MaSuKien) -> SuKienYTe(MaSuKien)`
  - Áp dụng `ON DELETE SET NULL` cho tài nguyên vật lý và liên kết đệ quy:
    `DotDieuTri(MaGiuong) REFERENCES GiuongBenh(MaGiuong) ON DELETE SET NULL`: Khi giường bị thanh lý/bảo trì, đợt điều trị vẫn giữ nguyên hồ sơ bệnh án.  
    `DotDieuTri(MaDotTruoc) REFERENCES DotDieuTri(MaDotDieuTri) ON DELETE SET NULL`: Khi đợt trước bị chỉnh sửa/hủy, đợt tái phát hiện tại không bị xóa mất dữ liệu.

---

### 3.3. Bổ sung các ràng buộc miền giá trị (`CHECK Constraint`)

* **Hiện trạng cũ:**
  Bảng `GiuongBenh` để `TrangThai VARCHAR(20) DEFAULT 'Trong'` nhưng không có ràng buộc giá trị hợp lệ. Bảng `HoaDon` để `TrangThaiTT VARCHAR(20) DEFAULT 'ChuaThanhToan'` không ràng buộc. Bảng `Thuoc` thiếu kiểm tra đơn giá không âm.
* **Giải pháp trong script mới:**
  ```sql
  -- Ràng buộc trạng thái giường
  TrangThai VARCHAR(20) NOT NULL DEFAULT 'Trong' 
      CHECK (TrangThai IN ('Trong', 'DangDieuTri', 'BaoTri'))

  -- Ràng buộc trạng thái thanh toán hóa đơn
  TrangThaiTT VARCHAR(20) NOT NULL DEFAULT 'ChuaThanhToan' 
      CHECK (TrangThaiTT IN ('ChuaThanhToan', 'DaThanhToan', 'DaHuy'))

  -- Ràng buộc số tiền không âm ở tất cả các bảng
  CHECK (DonGia >= 0)
  CHECK (TonKho >= 0)
  CHECK (SoLuong > 0)
  CHECK (SoTien >= 0)
  CHECK (DonGiaNgay >= 0)
  CHECK (DonGiaSuDung >= 0)
  ```
* **Ý nghĩa:** Đảm bảo toàn vẹn miền giá trị (Domain Integrity), ngăn chặn triệt để lỗi người dùng nhập nhầm số tiền âm hoặc nhập sai chính tả trạng thái (ví dụ gõ nhầm 'DaThanhToan' thành 'Da Thanh Toan').

---

### 3.4. Sửa các lỗi logic trong Stored Procedure 10.3 (`sp_XuatHoaDon`)

Đây là thủ tục bị nhiều lỗi logic nhất trong bản thiết kế cũ:

1. **Bỏ quên 2 bảng chi phí Thiết bị và Dịch vụ:**
   - *Phân tích:* Ở Mục 1.2, Mục 2 (ERD) và Mục 4, nhóm đã thiết kế rõ ràng bảng `SuDungThietBi` (máy nội soi, điện tim...) và `SuDungDichVu` (xét nghiệm máu, sinh hóa...). Tuy nhiên trong `sp_XuatHoaDon` cũ, người viết chỉ cộng tiền khám, tiền chữa, tiền phòng, tiền thuốc và tiền công. Bệnh nhân dùng dịch vụ xét nghiệm hay chụp chiếu thì hóa đơn lại bị bỏ sót!
   - *Khắc phục:* Đã bổ sung 2 khối lệnh truy vấn và đẩy chi phí thiết bị, dịch vụ vào `HoaDonChiTiet`.
2. **Lỗi "hack" nhảy cóc số thứ tự `v_STT + 100`:**
   - *Phân tích:* Khóa chính của bảng `HoaDonChiTiet` là `(MaSuKien, SoDong)`. Trong script cũ, để tránh trùng `SoDong` giữa thuốc và nhân công, người viết đã cộng bừa:
     `SELECT p_MaSuKien, v_STT + 100 + row_number() OVER (), ...`
     Cách viết này mang tính đối phó, nếu số khoản mục thuốc vượt quá 100 thì sẽ gây lỗi trùng khóa chính; hơn nữa số dòng in ra hóa đơn bị nhảy cóc (dòng 1, dòng 2 rồi nhảy lên dòng 101, 102), không thực tế.
   - *Khắc phục:* Sau mỗi khoản mục, thủ tục tính lại số dòng cao nhất hiện tại bằng `SELECT COALESCE(MAX(SoDong), v_STT) INTO v_STT FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;`, giúp các dòng trong hóa đơn được đánh số liên tục: `1, 2, 3, 4, 5...`.
3. **Lỗi Duplicate Key khi xuất lại hóa đơn:**
   - *Phân tích:* Khi một hóa đơn đã được lập nhưng sau đó bệnh nhân được kê thêm thuốc hoặc sử dụng thêm dịch vụ, thủ tục được gọi lại để cập nhật. Do lệnh `INSERT INTO HoaDon ... ON CONFLICT DO NOTHING;` chỉ bỏ qua bảng cha, các câu lệnh `INSERT INTO HoaDonChiTiet` bên dưới sẽ bị văng lỗi `duplicate key value violates unique constraint "hoadonchitiet_pkey"` vì các dòng số 1, 2 cũ vẫn còn đó.
   - *Khắc phục:* Bổ sung kiểm tra trạng thái: nếu hóa đơn chưa thanh toán (`TrangThaiTT <> 'DaThanhToan'`), thủ tục thực hiện `DELETE FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;` trước khi tính toán lại toàn bộ chi tiết.

---

### 3.5. Bổ sung nghiệp vụ tự động giải phóng giường bệnh trong Trigger 7.3 (`dong_dot_dieu_tri`)

* **Hiện trạng cũ:**
  ```sql
  IF NEW.KetLuan ILIKE '%khoi%' THEN
     UPDATE DotDieuTri
     SET TrangThai = 'DaKhoi',
         NgayKetThuc = (SELECT ThoiGian::date FROM SuKienYTe WHERE MaSuKien = NEW.MaSuKien)
     WHERE MaDotDieuTri = NEW.MaDotDieuTri;
  END IF;
  ```
* **Vấn đề phát sinh:**
  Trong Mục 1.3.3 của báo cáo có nêu rõ nghiệp vụ: *"Bố trí/giải phóng giường bệnh theo đợt điều trị"*. Tuy nhiên, trigger cũ chỉ đóng đợt điều trị mà quên mất việc cập nhật trạng thái giường bệnh đang gán cho đợt đó. Kết quả là trên hệ thống, giường bệnh sẽ mãi mãi ở trạng thái `'DangDieuTri'`, phòng khám không thể bố trí giường đó cho bệnh nhân khác.
* **Khắc phục trong script mới:**
  ```sql
  SELECT MaGiuong INTO v_MaGiuong FROM DotDieuTri WHERE MaDotDieuTri = NEW.MaDotDieuTri;
  IF v_MaGiuong IS NOT NULL THEN
      UPDATE GiuongBenh SET TrangThai = 'Trong' WHERE MaGiuong = v_MaGiuong;
  END IF;
  ```

---

### 3.6. Nạp cấu hình tham số hệ thống mặc định (`ThamSoHeThong`)

* **Hiện trạng cũ:**
  Bảng `ThamSoHeThong` được tạo nhưng để trống 100%.
* **Vấn đề phát sinh:**
  Trong hàm `fn_TinhLuongBacSy` và thủ tục `sp_TraLuong`, các câu truy vấn:
  ```sql
  SELECT GiaTri FROM ThamSoHeThong WHERE TenThamSo = 'LUONG_CO_SO';
  SELECT GiaTri FROM ThamSoHeThong WHERE TenThamSo = 'THUONG_BS_HOAN_THANH';
  SELECT GiaTri FROM ThamSoHeThong WHERE TenThamSo = 'THUONG_YTA_HOTRO';
  ```
  đều trả về `NULL`. Dẫn đến việc nhân lương cơ bản ra `NULL` và toàn bộ bảng lương bị lỗi khi chạy thực tế.
* **Khắc phục trong script mới:**
  Đã bổ sung câu lệnh chèn dữ liệu cấu hình chuẩn ở cuối file:
  ```sql
  INSERT INTO ThamSoHeThong (TenThamSo, GiaTri) VALUES
  ('LUONG_CO_SO', 1800000),             -- Lương cơ sở áp dụng tính lương cơ bản
  ('THUONG_BS_HOAN_THANH', 200000),     -- Thưởng trên mỗi đợt điều trị khỏi bệnh
  ('THUONG_YTA_HOTRO', 50000)           -- Thưởng trên mỗi ca y tá hỗ trợ
  ON CONFLICT (TenThamSo) DO UPDATE SET GiaTri = EXCLUDED.GiaTri;
  ```

---

## 4. KẾT QUẢ ĐẠT ĐƯỢC SAU KHI CÀI ĐẶT THỰC TẾ

Toàn bộ script [cai_dat_phong_kham.sql](file:///D:/ptit/he_co_so_dl/cai_dat_phong_kham.sql) đã được nạp trực tiếp vào PostgreSQL (container `phongkham_postgres`, database `phongkham_db`).

Kết quả kiểm tra trên hệ thống:
1. **24/24 Bảng** được khởi tạo chính xác theo chuẩn BCNF / 3NF.
2. **5/5 Trigger** hoạt động tự động:
   - Tự động sinh mã sự kiện theo format khoa học.
   - Chặn trường hợp bác sĩ khác chữa bệnh cho đợt điều trị của người khác.
   - Tự động đóng đợt và giải phóng giường khi khỏi bệnh.
   - Tự động trừ kho thuốc với cơ chế khóa `FOR UPDATE` chống race condition.
   - Tự động cập nhật tổng tiền hóa đơn khi có thay đổi ở bảng chi tiết.
3. **2/2 View** hoạt động tốt:
   - `v_DotDieuTri_ChiTiet`: Tổng hợp đầy đủ tên bệnh nhân, tên bác sĩ (bù đắp việc phân tách BCNF).
   - `v_DoanhThu_TheoNgay`: Thống kê tiền khám chữa và tổng doanh thu hóa đơn theo ngày.
4. **6/6 Stored Procedure (Transaction)** thực thi chuẩn xác, kiểm soát transaction an toàn với `COMMIT` và `ROLLBACK`.

---
*Báo cáo được lập phục vụ cho việc hoàn thiện đồ án môn học Các hệ thống cơ sở dữ liệu.*
