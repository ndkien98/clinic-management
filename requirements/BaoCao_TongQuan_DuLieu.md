# BÁO CÁO TỔNG QUAN VÀ THUYẾT MINH TẬP DỮ LIỆU MẪU
**Học viện Công nghệ Bưu chính Viễn thông (PTIT)**  
**Môn học:** Các hệ thống cơ sở dữ liệu  
**Đề tài 4:** Hệ thống quản lý phòng khám bệnh tư nhân  
**GVHD:** TS. Phan Thị Hà  
**File script:** `cai_dat_phong_kham.sql` (Phần 12: Seed Data)

---

## 1. MỤC TIÊU VÀ NGUYÊN TẮC THIẾT KẾ DỮ LIỆU

Để phục vụ tốt nhất cho việc đánh giá, kiểm thử các ràng buộc toàn vẹn, trigger và thủ tục lưu trữ (transaction), tập dữ liệu mẫu được xây dựng theo các nguyên tắc nghiêm ngặt:
1. **Tính chân thực 100% (Realistic):** Tuyệt đối không sử dụng dữ liệu giả định vô nghĩa (như Bệnh nhân A, B, Bác sĩ 1, 2, Thuốc A, B...). Mọi thông tin từ họ tên, địa chỉ, số CCCD, mặt bệnh y khoa, tên thuốc, biệt dược, thiết bị kỹ thuật cho đến quy trình khám chữa bệnh đều được mô phỏng chính xác theo hoạt động thực tế tại các phòng khám đa khoa tại Hà Nội.
2. **Độ phủ nghiệp vụ toàn diện:** Bao quát đầy đủ các tình huống nghiệp vụ thực tế:
   - Ca khám ban đầu và điều trị theo dõi nội trú (có bố trí giường bệnh).
   - Ca điều trị thành công (kết luận "đã khỏi", trigger tự động đổi trạng thái và giải phóng giường bệnh).
   - **Ca bệnh tái phát (Recursive Link):** Minh họa đợt điều trị mới liên kết đệ quy `MaDotTruoc` trỏ về đợt điều trị cũ đã khỏi.
   - Ca khám ngoại trú thông thường, làm xét nghiệm sàng lọc không mở đợt điều trị.
   - Ca làm thủ thuật chuyên khoa (Tai Mũi Họng, Răng Hàm Mặt) có phối hợp bác sĩ, y tá phụ tá, máy móc thiết bị và dịch vụ cận lâm sàng.
3. **Tính toàn vẹn và tự động hóa:** Dữ liệu nạp vào kích hoạt thành công toàn bộ 5 trigger của hệ thống (tự động trừ tồn kho thuốc, tự động tính tổng tiền hóa đơn, tự động kiểm tra bác sĩ phụ trách...).

---

## 2. THỐNG KÊ SỐ LƯỢNG BẢN GHI TRÊN 24 BẢNG DỮ LIỆU

Toàn bộ 24 bảng dữ liệu đã được nạp dữ liệu thành công trong PostgreSQL (`phongkham_db`):

| STT | Tên bảng | Nhóm nghiệp vụ | Số bản ghi | Ghi chú |
| :---: | :--- | :--- | :---: | :--- |
| 1 | `Khoa` | Danh mục gốc | **5** | Nội, Ngoại, Nhi, Tai Mũi Họng, Răng Hàm Mặt |
| 2 | `LoaiNhanCong` | Danh mục gốc | **5** | Khám tiêu chuẩn, khám ngoài giờ, thủ thuật, y tá, điều dưỡng |
| 3 | `BenhNhan` | Quản lý bệnh nhân | **8** | Hồ sơ bệnh nhân thực tế tại các quận Hà Nội |
| 4 | `DanhMucBenh` | Danh mục y khoa | **8** | Mã bệnh chuẩn theo các nhóm tim mạch, tiêu hóa, hô hấp... |
| 5 | `Thuoc` | Quản lý kho dược | **10** | Tân dược từ AstraZeneca, GSK, Sanofi, Dược Hậu Giang... |
| 6 | `ThietBi` | Trang thiết bị | **6** | Máy siêu âm 4D, máy điện tim, máy nội soi TMH, ghế nha khoa... |
| 7 | `DichVuYTe` | Dịch vụ kỹ thuật | **6** | Tổng phân tích máu, đường huyết, nội soi, X-Quang, khí dung... |
| 8 | `ThamSoHeThong` | Cấu hình hệ thống | **3** | Lương cơ sở (1.8tr), thưởng ca khỏi (200k), thưởng phụ tá (50k) |
| 9 | `NhanVienYTe` | Nhân sự (Lớp cha ISA) | **8** | 5 Bác sĩ + 3 Y tá điều dưỡng |
| 10 | `BacSy` | Nhân sự (Lớp con ISA) | **5** | TS, ThS, BSCKI, BSCKII theo chuyên khoa |
| 11 | `YTa` | Nhân sự (Lớp con ISA) | **3** | Có chứng chỉ hành nghề định dạng chuẩn Sở Y tế |
| 12 | `PhongKham` | Cơ sở vật chất | **6** | Phòng khám chuyên khoa và phòng lưu bệnh nội trú |
| 13 | `GiuongBenh` | Cơ sở vật chất | **6** | Giường bệnh tại các phòng lưu (Trống, Đang dùng, Bảo trì) |
| 14 | `SuKienYTe` | Giao dịch (Lớp cha ISA) | **13** | 7 Lượt khám (`KHAM`) + 6 Lượt chữa (`CHUA`) |
| 15 | `LanKham` | Giao dịch (Lớp con ISA) | **7** | Ghi nhận triệu chứng lâm sàng và tiền khám |
| 16 | `DotDieuTri` | Thực thể kết hợp (BCNF) | **6** | Có đợt đang mở, đợt đã khỏi, và đợt tái phát đệ quy |
| 17 | `LanChuaBenh` | Giao dịch (Lớp con ISA) | **6** | Chi tiết thủ thuật, kết luận điều trị và tiền công chữa |
| 18 | `SuDungThuoc` | Liên kết N-N | **10** | Kê đơn thuốc (tự động kích hoạt trigger trừ tồn kho) |
| 19 | `SuDungThietBi` | Liên kết N-N | **6** | Sử dụng máy móc phục vụ chẩn đoán / thủ thuật |
| 20 | `SuDungDichVu` | Liên kết N-N | **8** | Chỉ định xét nghiệm, chụp chiếu cận lâm sàng |
| 21 | `SuDungNhanCong` | Liên kết N-N | **16** | Phân bổ bác sĩ chính, bác sĩ khám và y tá hỗ trợ |
| 22 | `HoaDon` | Quản lý tài chính | **13** | Mỗi sự kiện y tế gắn liền 1 hóa đơn thanh toán |
| 23 | `HoaDonChiTiet` | Thực thể yếu | **57** | Từng khoản mục viện phí cấu thành nên hóa đơn |
| 24 | `Luong` | Tiền lương nhân sự | **10** | Bảng thanh toán lương tháng 07, 08 và 09/2026 |

---

## 3. CHI TIẾT CÁC DANH MỤC THỰC TẾ

### 3.1. Danh mục thuốc tân dược (`Thuoc`)
Các mặt thuốc được chọn lọc theo các bệnh lý phòng khám hay tiếp nhận:
- **Amlodipin 5mg** (Hãng: Dược Hậu Giang - DHG): Thuốc hạ áp chẹn kênh calci, đơn giá 3.500 đ/viên.
- **Nexium 40mg (Esomeprazol)** (Hãng: AstraZeneca): Thuốc ức chế bơm proton điều trị viêm loét dạ dày, đơn giá 24.000 đ/viên.
- **Augmentin 1g** (Hãng: GlaxoSmithKline - GSK): Kháng sinh phổ rộng Amoxicillin/Acid Clavulanic trị nhiễm khuẩn hô hấp/TMH, đơn giá 18.500 đ/viên.
- **Klamentin 500/62.5mg gói** (Hãng: DHG): Kháng sinh dạng gói vị ngọt chuyên dùng cho bệnh nhi, đơn giá 12.000 đ/gói.
- **Panadol Extra đỏ** (Hãng: GSK): Thuốc giảm đau hạ sốt Paracetamol + Cafein, đơn giá 2.000 đ/viên.
- **Rodogyl** (Hãng: Sanofi Aventis): Kháng sinh chuyên khoa răng hàm mặt (Spiramycin + Metronidazol), đơn giá 7.500 đ/viên.
- **Glucophage 850mg** (Hãng: Merck KGaA): Thuốc hạ đường huyết điều trị đái tháo đường týp 2, đơn giá 4.200 đ/viên.
- **Mobic 7.5mg** (Hãng: Boehringer Ingelheim): Thuốc chống viêm không steroid (Meloxicam) trị thoái hóa cột sống, đơn giá 14.000 đ/viên.
- **Otrivin 0.1%** (Hãng: Novartis): Thuốc xịt co mạch chống nghẹt mũi viêm xoang, đơn giá 55.000 đ/lọ.

### 3.2. Đội ngũ y bác sĩ (`NhanVienYTe`, `BacSy`, `YTa`)
Hệ thống quản lý 5 Bác sĩ và 3 Y tá điều dưỡng với trình độ và vị trí công tác cụ thể:
1. **TS.BS Nguyễn Khắc Hưng** (`NV_BS01`): Trưởng khoa Nội tổng hợp, chuyên sâu Nội Tim mạch - Chuyển hóa, hệ số lương 4.65.
2. **ThS.BS Trần Thanh Hằng** (`NV_BS02`): Bác sĩ phụ trách Nhi khoa, chuyên môn Hô hấp nhi, hệ số lương 3.99.
3. **BSCKI Đặng Quốc Tuấn** (`NV_BS03`): Bác sĩ chuyên khoa Tai Mũi Họng, chuyên nội soi và tiểu phẫu TMH, hệ số lương 4.32.
4. **ThS.BS Lê Mai Phương** (`NV_BS04`): Bác sĩ chuyên khoa Răng Hàm Mặt, chuyên nội nha và phục hình răng, hệ số lương 3.66.
5. **BSCKII Bùi Thế Anh** (`NV_BS05`): Bác sĩ chuyên khoa Ngoại tổng quát - Tiêu hóa, hệ số lương 4.98.
6. **CNĐD Hoàng Thị Lan** (`NV_YT01`): Cử nhân điều dưỡng đa khoa (CCHN: `001234/HNO-CCHN`), hệ số lương 2.67.
7. **ĐD Đỗ Thị Thúy** (`NV_YT02`): Điều dưỡng nhi khoa (CCHN: `005678/HNO-CCHN`), hệ số lương 2.34.
8. **ĐD Vũ Văn Nam** (`NV_YT03`): Điều dưỡng phụ tá thủ thuật ngoại/TMH (CCHN: `007890/HNO-CCHN`), hệ số lương 2.45.

---

## 4. BẢN ĐỒ CÁC CA BỆNH VÀ LUỒNG NGHIỆP VỤ MÔ PHỎNG

Tập dữ liệu xây dựng 6 kịch bản bệnh án mẫu mô phỏng toàn diện chu trình khám chữa bệnh tại phòng khám:

```
[Bệnh nhân đến] ---> [LanKham ban đầu] ---> [Phát hiện bệnh] ---> [Mở DotDieuTri]
                                                                          |
                                                                          v
[Xuất viện / Khỏi] <-- [Đóng DotDieuTri] <-- [LanChuaBenh (N lần)] <------+
```

### Case 1: Điều trị nội trú ngắn ngày - Bệnh Tăng huyết áp (`BENH01`)
* **Bệnh nhân:** Trần Văn Tuấn (`BN002`), 51 tuổi, trú tại Royal City, Thanh Xuân.
* **Bác sĩ phụ trách:** TS.BS Nguyễn Khắc Hưng (`NV_BS01`).
* **Diễn biến:**
  - Ngày 01/09/2026: Khám ban đầu (`NOI-BS01-K-20260901-0006`), huyết áp 165/100 mmHg, tức ngực. Làm điện tim 6 cần, xét nghiệm máu, xét nghiệm đường huyết.
  - Mở đợt điều trị `DT_20260901_001` (Mức độ nặng, dự kiến 3 lần chữa), bố trí nằm theo dõi tại giường `GB201_01` (Phòng Lưu bệnh nội khoa PK201). Kê 30 viên Amlodipin 5mg.
  - Ngày 03/09/2026: Lần chữa 1 (`NOI-BS01-C-20260903-0007`), điều dưỡng Hoàng Thị Lan đo huyết áp và theo dõi buồng bệnh. Huyết áp hạ về 138/85 mmHg. Đợt điều trị tiếp tục mở (`DangDieuTri`).

### Case 2: Bệnh nhi hô hấp - Đã điều trị KHỎI và tự động giải phóng giường (`BENH03`)
* **Bệnh nhân:** Bệnh nhi Lê Hoàng Long (`BN003`), 8 tuổi, trú tại Liễu Giai, Ba Đình.
* **Bác sĩ phụ trách:** ThS.BS Trần Thanh Hằng (`NV_BS02`).
* **Diễn biến:**
  - Ngày 20/08/2026: Khám ban đầu (`NHI-BS02-K-20260820-0003`), sốt cao 38.8 độ C, ho cơn khò khè. Mở đợt điều trị `DT_20260820_001`, bố trí giường lưu `GB202_01`. Kê kháng sinh Klamentin và hạ sốt Panadol.
  - Ngày 22/08/2026: Lần chữa 1 (`NHI-BS02-C-20260822-0004`), sử dụng máy hút dịch Medela và khí dung thuốc, y tá Đỗ Thị Thúy phụ tá.
  - Ngày 25/08/2026: Lần chữa 2 (`NHI-BS02-C-20260825-0005`), bác sĩ Hằng khám đánh giá: *"Phổi thông khí đều, hết khò khè, trẻ ăn ngủ tốt, đã khỏi hoàn toàn"*.
* **Cơ chế Trigger tự động:** Do kết luận chứa chữ "đã khỏi", **Trigger 7.3** đã tự động:
  1. Cập nhật `DotDieuTri.TrangThai = 'DaKhoi'`.
  2. Ghi nhận `NgayKetThuc = '2026-08-25'`.
  3. Cập nhật giải phóng giường `GiuongBenh.TrangThai = 'Trong'` cho mã giường `GB202_01`.

### Case 3: BỆNH TÁI PHÁT - Minh chứng sống động cho chuẩn hóa BCNF liên kết đệ quy (`BENH02`)
* **Bệnh nhân:** Phạm Thu Thảo (`BN004`), 31 tuổi, trú tại Phố Huế, Hoàn Kiếm.
* **Bác sĩ phụ trách:** TS.BS Nguyễn Khắc Hưng (`NV_BS01`).
* **Diễn biến:**
  - **Đợt 1 (Đã khỏi):** Khám ngày 10/07/2026 (`NOI-BS01-K-20260710-0001`), mở đợt `DT_20260710_001`. Siêu âm 4D, xét nghiệm máu, kê đơn Nexium 40mg. Ngày 25/07/2026 chữa nội soi (`NOI-BS01-C-20260725-0002`), kết luận ổ loét thành sẹo, **đã khỏi bệnh** và đóng đợt.
  - **Đợt 2 (Tái phát sau hơn 1 tháng):** Ngày 05/09/2026, bệnh nhân ăn đồ cay nóng bị đau rát thượng vị dữ dội trở lại, đến khám ngoài giờ (`NOI-BS01-K-20260905-0008`). Bác sĩ Hưng mở đợt điều trị mới `DT_20260905_001`, trong đó trường **`MaDotTruoc` trỏ về `DT_20260710_001`**.
* **Ý nghĩa học thuật:** Chứng minh cấu trúc tự tham chiếu đệ quy của thực thể kết hợp `DotDieuTri` theo đúng phân tích ở Mục 2 & Mục 4 của báo cáo đồ án.

### Case 4: Khám và làm thủ thuật Tai Mũi Họng (`BENH04`)
* **Bệnh nhân:** Nguyễn Thị Mai Hương (`BN001`), 38 tuổi, Đống Đa.
* **Bác sĩ:** BSCKI Đặng Quốc Tuấn (`NV_BS03`), Y tá phụ tá: ĐD Vũ Văn Nam (`NV_YT03`).
* **Diễn biến:** Khám ngày 10/09/2026, nội soi TMH ống mềm Pentax phát hiện viêm amidan hốc mủ. Mở đợt `DT_20260910_001`. Ngày 12/09/2026 làm thủ thuật hút mủ amidan tại phòng PK103, kê xịt mũi Otrivin và Augmentin 1g.

### Case 5: Khám và điều trị tủy Răng Hàm Mặt (`BENH05`)
* **Bệnh nhân:** Vũ Đức Thắng (`BN005`), 58 tuổi, Mỗ Lao, Hà Đông.
* **Bác sĩ:** ThS.BS Lê Mai Phương (`NV_BS04`).
* **Diễn biến:** Khám ngày 15/09/2026, răng 46 đau buốt dữ dội. Lấy cao răng, kê đơn Rodogyl và giảm đau. Mở đợt `DT_20260915_001`. Ngày 18/09/2026 điều trị diệt tủy răng trên ghế nha khoa Anthos A3.

### Case 6: Khám sức khỏe định kỳ (Sàng lọc - Không mở đợt điều trị)
* **Bệnh nhân:** Hoàng Minh Trí (`BN007`), 44 tuổi, Tây Hồ.
* **Bác sĩ:** TS.BS Nguyễn Khắc Hưng (`NV_BS01`).
* **Diễn biến:** Ngày 20/09/2026 khám tổng quát theo yêu cầu (`NOI-BS01-K-20260920-0013`), đo điện tim 6 cần, xét nghiệm máu 18 thông số, định lượng đường huyết tĩnh mạch. Kết quả bình thường, bác sĩ tư vấn chế độ ăn uống, **không phát sinh đợt điều trị**.

---

## 5. BẢNG TỔNG HỢP VIỆN PHÍ VÀ DOANH THU THỰC TẾ

Nhờ **Trigger 7.5** (`trg_capnhat_tong_tien`), mỗi khi các dòng chi tiết được chèn vào `HoaDonChiTiet`, tổng tiền trong `HoaDon` được cập nhật tức thời:

| Mã sự kiện | Ngày lập | Loại sự kiện | Bệnh nhân | Bác sĩ phụ trách | Khoản mục chính | Tổng tiền hóa đơn | Trạng thái |
| :--- | :---: | :---: | :--- | :--- | :--- | :---: | :---: |
| `NOI-BS01-K-20260710-0001` | 10/07/2026 | KHAM | Phạm Thu Thảo | TS.BS Nguyễn Khắc Hưng | Khám, Siêu âm 4D, XN máu, Nexium, Công BS | **956.000 đ** | Đã thanh toán |
| `NOI-BS01-C-20260725-0002` | 25/07/2026 | CHUA | Phạm Thu Thảo | TS.BS Nguyễn Khắc Hưng | Chữa nội soi, Tiền phòng, Công thủ thuật | **350.000 đ** | Đã thanh toán |
| `NHI-BS02-K-20260820-0003` | 20/08/2026 | KHAM | Lê Hoàng Long | ThS.BS Trần Thanh Hằng | Khám nhi, Klamentin, Panadol, Công BS | **440.000 đ** | Đã thanh toán |
| `NHI-BS02-C-20260822-0004` | 22/08/2026 | CHUA | Lê Hoàng Long | ThS.BS Trần Thanh Hằng | Chữa phế quản, Hút dịch, Khí dung, Công BS, YT | **350.000 đ** | Đã thanh toán |
| `NHI-BS02-C-20260825-0005` | 25/08/2026 | CHUA | Lê Hoàng Long | ThS.BS Trần Thanh Hằng | Khám xuất viện, Công bác sĩ | **180.000 đ** | Đã thanh toán |
| `NOI-BS01-K-20260901-0006` | 01/09/2026 | KHAM | Trần Văn Tuấn | TS.BS Nguyễn Khắc Hưng | Khám tim mạch, Điện tim, XN máu, Đường huyết, Amlodipin | **650.000 đ** | Đã thanh toán |
| `NOI-BS01-C-20260903-0007` | 03/09/2026 | CHUA | Trần Văn Tuấn | TS.BS Nguyễn Khắc Hưng | Điều trị hạ áp, Tiền phòng, Công BS, Điều dưỡng | **350.000 đ** | Đã thanh toán |
| `NOI-BS01-K-20260905-0008` | 05/09/2026 | KHAM | Phạm Thu Thảo | TS.BS Nguyễn Khắc Hưng | Khám ngoài giờ (tái phát), Nexium, Công BS ngoài giờ | **736.000 đ** | Đã thanh toán |
| `TMH-BS03-K-20260910-0009` | 10/09/2026 | KHAM | Nguyễn Thị Mai Hương | BSCKI Đặng Quốc Tuấn | Khám TMH, Nội soi Pentax, Augmentin, Panadol, Công BS | **909.000 đ** | Đã thanh toán |
| `TMH-BS03-C-20260912-0010` | 12/09/2026 | CHUA | Nguyễn Thị Mai Hương | BSCKI Đặng Quốc Tuấn | Thủ thuật hút mủ, Tiền phòng, Xịt Otrivin, Công BS, YT | **355.000 đ** | Đã thanh toán |
| `RHM-BS04-K-20260915-0011` | 15/09/2026 | KHAM | Vũ Đức Thắng | ThS.BS Lê Mai Phương | Khám RHM, Ghế nha khoa, Lấy cao răng, Rodogyl, Công BS | **720.000 đ** | Đã thanh toán |
| `RHM-BS04-C-20260918-0012` | 18/09/2026 | CHUA | Vũ Đức Thắng | ThS.BS Lê Mai Phương | Điều trị diệt tủy, Tiền phòng nha khoa, Công BS | **310.000 đ** | *Chưa thanh toán* |
| `NOI-BS01-K-20260920-0013` | 20/09/2026 | KHAM | Hoàng Minh Trí | TS.BS Nguyễn Khắc Hưng | Khám tổng quát, Điện tim, XN máu, Đường huyết, Công BS | **695.000 đ** | Đã thanh toán |

---

## 6. BẢNG LƯƠNG NHÂN SỰ VÀ CÔNG THỨC TÍNH TOÁN

Dữ liệu bảng `Luong` khớp hoàn toàn với quy tắc nghiệp vụ trong đồ án:
* **Lương cơ bản** = Hệ số lương $\times$ 1.800.000 đ.
* **Tiền thưởng Bác sĩ** = Số ca điều trị khỏi trong tháng $\times$ 200.000 đ.
* **Tiền thưởng Y tá** = Số lượt tham gia hỗ trợ khám chữa trong tháng $\times$ 50.000 đ.

| Mã phiếu lương | Nhân viên | Chức danh / Khoa | Tháng | Lương cơ bản | Tiền thưởng | Tổng thực lĩnh | Thuyết minh nghiệp vụ |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `LG-BS01-202607` | TS.BS Nguyễn Khắc Hưng | Bác sĩ - Nội | 07/2026 | 8.370.000 đ | 200.000 đ | **8.570.000 đ** | Thưởng 1 ca khỏi bệnh dạ dày (BN004) |
| `LG-YT01-202607` | CNĐD Hoàng Thị Lan | Y tá - Nội | 07/2026 | 4.806.000 đ | 0 đ | **4.806.000 đ** | Lương chuẩn theo ngạch bậc |
| `LG-BS02-202608` | ThS.BS Trần Thanh Hằng | Bác sĩ - Nhi | 08/2026 | 7.182.000 đ | 200.000 đ | **7.382.000 đ** | Thưởng 1 ca khỏi phế quản nhi (BN003) |
| `LG-YT02-202608` | ĐD Đỗ Thị Thúy | Y tá - Nhi | 08/2026 | 4.212.000 đ | 50.000 đ | **4.262.000 đ** | Thưởng 1 lượt phụ tá khí dung ngày 22/08 |
| `LG-BS01-202609` | TS.BS Nguyễn Khắc Hưng | Bác sĩ - Nội | 09/2026 | 8.370.000 đ | 0 đ | **8.370.000 đ** | Tạm ứng lương tháng 09/2026 |
| `LG-BS03-202609` | BSCKI Đặng Quốc Tuấn | Bác sĩ - TMH | 09/2026 | 7.776.000 đ | 0 đ | **7.776.000 đ** | Tạm ứng lương tháng 09/2026 |
| `LG-BS04-202609` | ThS.BS Lê Mai Phương | Bác sĩ - RHM | 09/2026 | 6.588.000 đ | 0 đ | **6.588.000 đ** | Tạm ứng lương tháng 09/2026 |
| `LG-BS05-202609` | BSCKII Bùi Thế Anh | Bác sĩ - Ngoại | 09/2026 | 8.964.000 đ | 0 đ | **8.964.000 đ** | Tạm ứng lương tháng 09/2026 |
| `LG-YT01-202609` | CNĐD Hoàng Thị Lan | Y tá - Nội | 09/2026 | 4.806.000 đ | 0 đ | **4.806.000 đ** | Tạm ứng lương tháng 09/2026 |
| `LG-YT03-202609` | ĐD Vũ Văn Nam | Y tá - TMH | 09/2026 | 4.410.000 đ | 50.000 đ | **4.460.000 đ** | Thưởng 1 ca phụ tá hút mủ ngày 12/09 |

---

## 7. CÁC CÂU LỆNH TRUY VẤN MẪU ĐỂ CHỤP ẢNH MINH HỌA (MỤC 5.4 BÁO CÁO)

Khi làm báo cáo Mục 5.4, bạn có thể chạy trực tiếp các câu lệnh sau để lấy kết quả và chụp ảnh màn hình:

### 7.1. Liệt kê các đợt điều trị kèm thông tin bệnh nhân và bác sĩ (Mục 5.4.1)
```sql
SELECT 
    MaDotDieuTri AS "Mã Đợt", 
    TenBenhNhan AS "Bệnh Nhân", 
    TenBacSy AS "Bác Sĩ Phụ Trách", 
    TenBenh AS "Chẩn Đoán Bệnh", 
    MucDoNang AS "Mức Độ", 
    NgayBatDau AS "Ngày Bắt Đầu", 
    TrangThai AS "Trạng Thái"
FROM v_DotDieuTri_ChiTiet;
```

### 7.2. Tra cứu lịch sử khám chữa bệnh của bệnh nhân Phạm Thu Thảo (Mục 5.4.2)
```sql
SELECT 
    se.MaSuKien, 
    se.ThoiGian, 
    se.LoaiSuKien, 
    nv.HoTen AS BacSy, 
    COALESCE(lk.TrieuChung, lc.HinhThucChua) AS NoiDung, 
    COALESCE(lc.KetLuan, 'Khám ban đầu') AS KetLuan
FROM SuKienYTe se
JOIN BenhNhan bn ON bn.MaBN = se.MaBN
JOIN NhanVienYTe nv ON nv.MaNV = se.MaBS
LEFT JOIN LanKham lk ON lk.MaSuKien = se.MaSuKien
LEFT JOIN LanChuaBenh lc ON lc.MaSuKien = se.MaSuKien
WHERE bn.HoTen = 'Phạm Thu Thảo'
ORDER BY se.ThoiGian;
```

### 7.3. Thống kê doanh thu theo ngày (Mục 5.4.3)
```sql
SELECT 
    Ngay AS "Ngày", 
    TienKhamChua AS "Tiền Khám & Chữa", 
    TongDoanhThuHoaDon AS "Tổng Viện Phí Hóa Đơn"
FROM v_DoanhThu_TheoNgay
ORDER BY Ngay;
```

### 7.4. Danh sách các ca bệnh tái phát (Mục 5.4.9)
```sql
SELECT 
    dt.MaDotDieuTri AS "Đợt Tái Phát", 
    bn.HoTen AS "Bệnh Nhân", 
    db.TenBenh AS "Bệnh Lý", 
    dt.NgayBatDau AS "Ngày Tái Phát", 
    dt.MaDotTruoc AS "Tham Chiếu Đợt Trước"
FROM DotDieuTri dt
JOIN LanKham lk ON lk.MaSuKien = dt.MaSuKienKham
JOIN SuKienYTe se ON se.MaSuKien = lk.MaSuKien
JOIN BenhNhan bn ON bn.MaBN = se.MaBN
JOIN DanhMucBenh db ON db.MaBenh = dt.MaBenh
WHERE dt.MaDotTruoc IS NOT NULL;
```

### 7.5. Chi tiết một hóa đơn cụ thể (Mục 5.4.8)
```sql
SELECT 
    hd.MaSuKien, 
    hd.NgayLap, 
    ct.SoDong, 
    ct.MoTaKhoanMuc, 
    ct.SoTien, 
    hd.TongTien, 
    hd.TrangThaiTT
FROM HoaDon hd
JOIN HoaDonChiTiet ct ON ct.MaSuKien = hd.MaSuKien
WHERE hd.MaSuKien = 'NOI-BS01-K-20260901-0006'
ORDER BY ct.SoDong;
```

---
*Báo cáo tổng quan dữ liệu được lập phục vụ việc hoàn thiện đồ án và chạy thực nghiệm trên hệ quản trị PostgreSQL.*
