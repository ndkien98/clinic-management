-- =====================================================================
-- BÀI TẬP LỚN: CÁC HỆ THỐNG CƠ SỞ DỮ LIỆU
-- ĐỀ TÀI 4: HỆ THỐNG QUẢN LÝ PHÒNG KHÁM BỆNH TƯ NHÂN
-- GVHD: TS. Phan Thị Hà
-- Lớp: M26CQHT03-B
-- 
-- Script cài đặt toàn bộ CSDL trên PostgreSQL:
-- Bao gồm:
--   - 24 Bảng chuẩn hóa BCNF / 3NF
--   - 5 Trigger ràng buộc toàn vẹn & nghiệp vụ tự động
--   - 2 Function hỗ trợ tính toán & tra cứu
--   - 2 View tổng hợp dữ liệu
--   - 6 Stored Procedure (Transaction xử lý nghiệp vụ)
-- =====================================================================

-- Xóa các bảng cũ theo thứ tự quan hệ ngược chiều (bảng con xóa trước, bảng cha xóa sau)
DROP TABLE IF EXISTS HoaDonChiTiet CASCADE;
DROP TABLE IF EXISTS HoaDon CASCADE;
DROP TABLE IF EXISTS SuDungDichVu CASCADE;
DROP TABLE IF EXISTS SuDungThietBi CASCADE;
DROP TABLE IF EXISTS SuDungThuoc CASCADE;
DROP TABLE IF EXISTS SuDungNhanCong CASCADE;
DROP TABLE IF EXISTS LanChuaBenh CASCADE;
DROP TABLE IF EXISTS DotDieuTri CASCADE;
DROP TABLE IF EXISTS LanKham CASCADE;
DROP TABLE IF EXISTS SuKienYTe CASCADE;
DROP TABLE IF EXISTS GiuongBenh CASCADE;
DROP TABLE IF EXISTS PhongKham CASCADE;
DROP TABLE IF EXISTS Luong CASCADE;
DROP TABLE IF EXISTS YTa CASCADE;
DROP TABLE IF EXISTS BacSy CASCADE;
DROP TABLE IF EXISTS NhanVienYTe CASCADE;
DROP TABLE IF EXISTS ThamSoHeThong CASCADE;
DROP TABLE IF EXISTS DichVuYTe CASCADE;
DROP TABLE IF EXISTS ThietBi CASCADE;
DROP TABLE IF EXISTS Thuoc CASCADE;
DROP TABLE IF EXISTS DanhMucBenh CASCADE;
DROP TABLE IF EXISTS BenhNhan CASCADE;
DROP TABLE IF EXISTS LoaiNhanCong CASCADE;
DROP TABLE IF EXISTS Khoa CASCADE;
DROP SEQUENCE IF EXISTS seq_sukien CASCADE;


-- =====================================================================
-- PHẦN 1: CÁC BẢNG DANH MỤC GỐC (Độc lập, không có khóa ngoại)
-- =====================================================================

-- 1. Khoa chuyên môn trong phòng khám (Nội, Ngoại, Nhi, Tai Mũi Họng...)
CREATE TABLE Khoa (
    MaKhoa      VARCHAR(10) PRIMARY KEY,
    TenKhoa     VARCHAR(100) NOT NULL,
    MoTa        TEXT
);

-- 2. Danh mục định mức tiền công cho các vị trí khám, chữa, phụ tá
CREATE TABLE LoaiNhanCong (
    MaLoaiCong    VARCHAR(10) PRIMARY KEY,
    TenLoaiCong   VARCHAR(100) NOT NULL,
    DonGiaMacDinh NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (DonGiaMacDinh >= 0)
);

-- 3. Hồ sơ bệnh nhân đến khám và điều trị
CREATE TABLE BenhNhan (
    MaBN        VARCHAR(10) PRIMARY KEY,
    HoTen       VARCHAR(100) NOT NULL,
    GioiTinh    CHAR(1) CHECK (GioiTinh IN ('M', 'F')), -- M: Nam, F: Nu
    NgaySinh    DATE,
    SDT         VARCHAR(15),
    DiaChi      VARCHAR(200),
    SoCCCD      VARCHAR(20) UNIQUE,
    NgayDangKy  DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 4. Danh mục các mặt bệnh theo phân loại y khoa
CREATE TABLE DanhMucBenh (
    MaBenh      VARCHAR(10) PRIMARY KEY,
    TenBenh     VARCHAR(150) NOT NULL,
    NhomBenh    VARCHAR(50),
    MoTa        TEXT
);

-- 5. Kho thuốc của phòng khám (quản lý số lượng tồn và giá bán hiện hành)
CREATE TABLE Thuoc (
    MaThuoc     VARCHAR(10) PRIMARY KEY,
    TenThuoc    VARCHAR(150) NOT NULL,
    DonViTinh   VARCHAR(20),
    DonGia      NUMERIC(12, 0) NOT NULL CHECK (DonGia >= 0),
    HangSX      VARCHAR(100),
    TonKho      INT NOT NULL DEFAULT 0 CHECK (TonKho >= 0)
);

-- 6. Danh mục thiết bị y tế (máy siêu âm, điện tim, nội soi...)
CREATE TABLE ThietBi (
    MaThietBi    VARCHAR(10) PRIMARY KEY,
    TenThietBi   VARCHAR(150) NOT NULL,
    DonGiaSuDung NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (DonGiaSuDung >= 0)
);

-- 7. Danh mục dịch vụ y tế kỹ thuật (xét nghiệm máu, chụp X-Quang...)
CREATE TABLE DichVuYTe (
    MaDV        VARCHAR(10) PRIMARY KEY,
    TenDV       VARCHAR(150) NOT NULL,
    DonGia      NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (DonGia >= 0)
);

-- 8. Bảng cấu hình các tham số động dùng chung (lương cơ sở, mức thưởng...)
CREATE TABLE ThamSoHeThong (
    TenThamSo   VARCHAR(50) PRIMARY KEY,
    GiaTri      NUMERIC(14, 0) NOT NULL
);


-- =====================================================================
-- PHẦN 2: QUẢN LÝ NHÂN SỰ Y TẾ (MÔ HÌNH KẾ THỪA ISA) VÀ LƯƠNG
-- =====================================================================

-- 9. Lớp cha ISA: Toàn bộ cán bộ, nhân viên y tế làm việc tại phòng khám
CREATE TABLE NhanVienYTe (
    MaNV        VARCHAR(10) PRIMARY KEY,
    HoTen       VARCHAR(100) NOT NULL,
    GioiTinh    CHAR(1) CHECK (GioiTinh IN ('M', 'F')),
    NgaySinh    DATE,
    SDT         VARCHAR(15),
    MaKhoa      VARCHAR(10) NOT NULL REFERENCES Khoa(MaKhoa),
    HeSoLuong   NUMERIC(4, 2) NOT NULL CHECK (HeSoLuong > 0),
    NgayVaoLam  DATE NOT NULL,
    LoaiNV      VARCHAR(10) NOT NULL CHECK (LoaiNV IN ('BACSY', 'YTA'))
);

-- 10. Lớp con ISA: Bác sĩ điều trị (kế thừa từ NhanVienYTe)
-- Giữ MaNV làm khóa chính và khóa ngoại để chuẩn theo ánh xạ ISA
CREATE TABLE BacSy (
    MaNV        VARCHAR(10) PRIMARY KEY REFERENCES NhanVienYTe(MaNV) ON DELETE CASCADE ON UPDATE CASCADE,
    Email       VARCHAR(100),
    ChuyenMon   VARCHAR(100)
);

-- 11. Lớp con ISA: Y tá, điều dưỡng hỗ trợ
CREATE TABLE YTa (
    MaNV             VARCHAR(10) PRIMARY KEY REFERENCES NhanVienYTe(MaNV) ON DELETE CASCADE ON UPDATE CASCADE,
    ChungChiHanhNghe VARCHAR(100)
);

-- 12. Bảng lương hàng tháng của nhân viên y tế
CREATE TABLE Luong (
    MaLuong       VARCHAR(20) PRIMARY KEY,
    MaNV          VARCHAR(10) NOT NULL REFERENCES NhanVienYTe(MaNV),
    Thang         DATE NOT NULL, -- Quy ước lưu ngày đầu tháng (ví dụ 2026-09-01)
    NgayNhanLuong DATE DEFAULT CURRENT_DATE,
    LuongCoBan    NUMERIC(12, 0) NOT NULL CHECK (LuongCoBan >= 0),
    TienThuong    NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (TienThuong >= 0),
    TongLuong     NUMERIC(12, 0) NOT NULL CHECK (TongLuong >= 0),
    GhiChu        TEXT,
    UNIQUE (MaNV, Thang)
);


-- =====================================================================
-- PHẦN 3: CƠ SỞ VẬT CHẤT (PHÒNG KHÁM VÀ GIƯỜNG BỆNH)
-- =====================================================================

-- 13. Phòng chức năng, phòng khám thuộc từng chuyên khoa
CREATE TABLE PhongKham (
    MaPhong      VARCHAR(10) PRIMARY KEY,
    TenPhong     VARCHAR(100) NOT NULL,
    ChucNang     VARCHAR(100),
    MaKhoa       VARCHAR(10) NOT NULL REFERENCES Khoa(MaKhoa),
    DonGiaSuDung NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (DonGiaSuDung >= 0)
);

-- 14. Giường lưu bệnh nhân theo dõi điều trị đặt tại phòng
CREATE TABLE GiuongBenh (
    MaGiuong    VARCHAR(10) PRIMARY KEY,
    MaPhong     VARCHAR(10) NOT NULL REFERENCES PhongKham(MaPhong),
    TrangThai   VARCHAR(20) NOT NULL DEFAULT 'Trong' CHECK (TrangThai IN ('Trong', 'DangDieuTri', 'BaoTri')),
    DonGiaNgay  NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (DonGiaNgay >= 0)
);


-- =====================================================================
-- PHẦN 4: SỰ KIỆN Y TẾ VÀ ĐỢT ĐIỀU TRỊ (GIAO DỊCH TRUNG TÂM)
-- =====================================================================

-- Sequence sinh số thứ tự tự động cho mã sự kiện y tế
CREATE SEQUENCE IF NOT EXISTS seq_sukien START 1;

-- 15. Lớp cha ISA: Sự kiện y tế ghi nhận mọi lượt bệnh nhân đến phòng khám
CREATE TABLE SuKienYTe (
    MaSuKien    VARCHAR(50) PRIMARY KEY,
    MaBN        VARCHAR(10) NOT NULL REFERENCES BenhNhan(MaBN),
    MaBS        VARCHAR(10) NOT NULL REFERENCES BacSy(MaNV),
    ThoiGian    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LoaiSuKien  VARCHAR(10) NOT NULL CHECK (LoaiSuKien IN ('KHAM', 'CHUA'))
);

-- 16. Lớp con ISA: Lần khám ban đầu (có thể phát hiện bệnh để mở đợt điều trị)
CREATE TABLE LanKham (
    MaSuKien    VARCHAR(50) PRIMARY KEY REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    MaKhoa      VARCHAR(10) NOT NULL REFERENCES Khoa(MaKhoa),
    TrieuChung  TEXT,
    TienKham    NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (TienKham >= 0)
);

-- 17. Thực thể kết hợp: Đợt điều trị (chuẩn hóa BCNF: không lưu MaBN/MaBS trực tiếp)
-- Liên kết đệ quy MaDotTruoc để theo dõi các trường hợp bệnh nhân bị tái phát
CREATE TABLE DotDieuTri (
    MaDotDieuTri    VARCHAR(50) PRIMARY KEY,
    MaSuKienKham    VARCHAR(50) NOT NULL REFERENCES LanKham(MaSuKien),
    MaBenh          VARCHAR(10) NOT NULL REFERENCES DanhMucBenh(MaBenh),
    MucDoNang       VARCHAR(10) CHECK (MucDoNang IN ('Nhe', 'Vua', 'Nang')),
    SoLanChuaDuKien INT CHECK (SoLanChuaDuKien > 0),
    NgayBatDau      DATE NOT NULL DEFAULT CURRENT_DATE,
    NgayKetThuc     DATE,
    TrangThai       VARCHAR(20) NOT NULL DEFAULT 'DangDieuTri' CHECK (TrangThai IN ('DangDieuTri', 'DaKhoi')),
    MaGiuong        VARCHAR(10) REFERENCES GiuongBenh(MaGiuong) ON DELETE SET NULL,
    MaDotTruoc      VARCHAR(50) REFERENCES DotDieuTri(MaDotDieuTri) ON DELETE SET NULL,
    CHECK (NgayKetThuc IS NULL OR NgayKetThuc >= NgayBatDau)
);

-- 18. Lớp con ISA: Lần chữa bệnh cụ thể trong đợt điều trị đang mở
CREATE TABLE LanChuaBenh (
    MaSuKien     VARCHAR(50) PRIMARY KEY REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    MaDotDieuTri VARCHAR(50) NOT NULL REFERENCES DotDieuTri(MaDotDieuTri),
    HinhThucChua VARCHAR(100) NOT NULL,
    KetLuan      TEXT,
    TienChua     NUMERIC(12, 0) NOT NULL DEFAULT 0 CHECK (TienChua >= 0),
    MaPhong      VARCHAR(10) NOT NULL REFERENCES PhongKham(MaPhong)
);


-- =====================================================================
-- PHẦN 5: CÁC BẢNG QUAN HỆ NHIỀU - NHIỀU (VẬT TƯ, THIẾT BỊ, NHÂN CÔNG)
-- =====================================================================

-- 19. Ghi nhận nhân sự y tế (bác sĩ, y tá) tham gia ca khám/chữa và tính công
CREATE TABLE SuDungNhanCong (
    MaSuKien     VARCHAR(50) REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    MaNV         VARCHAR(10) REFERENCES NhanVienYTe(MaNV),
    MaLoaiCong   VARCHAR(10) NOT NULL REFERENCES LoaiNhanCong(MaLoaiCong),
    VaiTro       VARCHAR(50),
    DonGiaApDung NUMERIC(12, 0) NOT NULL CHECK (DonGiaApDung >= 0),
    PRIMARY KEY (MaSuKien, MaNV)
);

-- 20. Ghi nhận thuốc kê đơn sử dụng trong sự kiện y tế
CREATE TABLE SuDungThuoc (
    MaSuKien     VARCHAR(50) REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    MaThuoc      VARCHAR(10) REFERENCES Thuoc(MaThuoc),
    SoLuong      INT NOT NULL CHECK (SoLuong > 0),
    DonGiaApDung NUMERIC(12, 0) NOT NULL CHECK (DonGiaApDung >= 0),
    PRIMARY KEY (MaSuKien, MaThuoc)
);

-- 21. Ghi nhận việc sử dụng máy móc, thiết bị y tế trong sự kiện y tế
CREATE TABLE SuDungThietBi (
    MaSuKien     VARCHAR(50) REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    MaThietBi    VARCHAR(10) REFERENCES ThietBi(MaThietBi),
    SoLuong      INT NOT NULL DEFAULT 1 CHECK (SoLuong > 0),
    DonGiaApDung NUMERIC(12, 0) NOT NULL CHECK (DonGiaApDung >= 0),
    PRIMARY KEY (MaSuKien, MaThietBi)
);

-- 22. Ghi nhận dịch vụ kỹ thuật (chụp chiếu, xét nghiệm...) đã thực hiện
CREATE TABLE SuDungDichVu (
    MaSuKien     VARCHAR(50) REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    MaDV         VARCHAR(10) REFERENCES DichVuYTe(MaDV),
    SoLuong      INT NOT NULL DEFAULT 1 CHECK (SoLuong > 0),
    DonGiaApDung NUMERIC(12, 0) NOT NULL CHECK (DonGiaApDung >= 0),
    PRIMARY KEY (MaSuKien, MaDV)
);


-- =====================================================================
-- PHẦN 6: QUẢN LÝ HÓA ĐƠN VÀ CHI TIẾT THANH TOÁN
-- =====================================================================

-- 23. Hóa đơn tổng thanh toán cho từng sự kiện y tế (quan hệ 1-1)
CREATE TABLE HoaDon (
    MaSuKien    VARCHAR(50) PRIMARY KEY REFERENCES SuKienYTe(MaSuKien) ON DELETE CASCADE,
    NgayLap     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TongTien    NUMERIC(14, 0) NOT NULL DEFAULT 0 CHECK (TongTien >= 0),
    TrangThaiTT VARCHAR(20) NOT NULL DEFAULT 'ChuaThanhToan' 
                CHECK (TrangThaiTT IN ('ChuaThanhToan', 'DaThanhToan', 'DaHuy'))
);

-- 24. Thực thể yếu: Chi tiết từng khoản mục chi phí cấu thành nên hóa đơn
CREATE TABLE HoaDonChiTiet (
    MaSuKien     VARCHAR(50) REFERENCES HoaDon(MaSuKien) ON DELETE CASCADE,
    SoDong       INT NOT NULL CHECK (SoDong > 0),
    MoTaKhoanMuc VARCHAR(200) NOT NULL,
    SoTien       NUMERIC(12, 0) NOT NULL CHECK (SoTien >= 0),
    PRIMARY KEY (MaSuKien, SoDong)
);


-- =====================================================================
-- PHẦN 7: CÀI ĐẶT 5 TRIGGER RÀNG BUỘC TOÀN VẸN VÀ TỰ ĐỘNG HÓA
-- =====================================================================

-- 7.1 Tự động sinh mã sự kiện y tế theo quy ước: <MaKhoa>-<MaBS>-<K/C>-<YYYYMMDD>-<STT 4 số>
-- Chạy khi thêm bản ghi mới mà không truyền MaSuKien (để NULL hoặc rỗng)
CREATE OR REPLACE FUNCTION fn_trg_sinh_ma_sukien()
RETURNS TRIGGER AS $$
DECLARE
    v_MaKhoa VARCHAR(10);
    v_stt INT;
BEGIN
    -- Lấy mã khoa của bác sĩ phụ trách sự kiện
    SELECT MaKhoa INTO v_MaKhoa FROM NhanVienYTe WHERE MaNV = NEW.MaBS;
    IF v_MaKhoa IS NULL THEN
        v_MaKhoa := 'KHOA';
    END IF;

    -- Lấy số thứ tự tiếp theo từ sequence
    v_stt := nextval('seq_sukien');

    IF NEW.ThoiGian IS NULL THEN
        NEW.ThoiGian := CURRENT_TIMESTAMP;
    END IF;

    -- Ghép mã sự kiện
    NEW.MaSuKien := v_MaKhoa || '-' || NEW.MaBS || '-' ||
                    CASE NEW.LoaiSuKien WHEN 'KHAM' THEN 'K' ELSE 'C' END || '-' ||
                    to_char(NEW.ThoiGian, 'YYYYMMDD') || '-' || lpad(v_stt::text, 4, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sinh_ma_sukien
BEFORE INSERT ON SuKienYTe
FOR EACH ROW
WHEN (NEW.MaSuKien IS NULL OR NEW.MaSuKien = '')
EXECUTE FUNCTION fn_trg_sinh_ma_sukien();


-- 7.2 Ràng buộc nghiệp vụ: Một đợt điều trị chỉ do duy nhất bác sĩ phụ trách ban đầu thực hiện
CREATE OR REPLACE FUNCTION fn_trg_kiemtra_bacsy_dotdieutri()
RETURNS TRIGGER AS $$
DECLARE
    v_MaBS_ChuaBenh VARCHAR(10);
    v_MaBS_PhuTrach VARCHAR(10);
BEGIN
    -- Lấy bác sĩ của lượt chữa này
    SELECT MaBS INTO v_MaBS_ChuaBenh FROM SuKienYTe WHERE MaSuKien = NEW.MaSuKien;

    -- Lấy bác sĩ phụ trách đợt điều trị (qua lần khám khởi tạo đợt)
    SELECT se.MaBS INTO v_MaBS_PhuTrach
    FROM DotDieuTri dt
    JOIN SuKienYTe se ON se.MaSuKien = dt.MaSuKienKham
    WHERE dt.MaDotDieuTri = NEW.MaDotDieuTri;

    IF v_MaBS_PhuTrach IS NULL THEN
        RAISE EXCEPTION 'Khong tim thay dot dieu tri %', NEW.MaDotDieuTri;
    END IF;

    IF v_MaBS_ChuaBenh <> v_MaBS_PhuTrach THEN
        RAISE EXCEPTION 'Lan chua benh (%): phai do dung bac sy phu trach (%) thuc hien, khong phai bac sy %',
            NEW.MaSuKien, v_MaBS_PhuTrach, v_MaBS_ChuaBenh;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_kiemtra_bacsy
BEFORE INSERT OR UPDATE ON LanChuaBenh
FOR EACH ROW
EXECUTE FUNCTION fn_trg_kiemtra_bacsy_dotdieutri();


-- 7.3 Tự động đóng đợt điều trị khi có kết luận "đã khỏi" và giải phóng giường bệnh
CREATE OR REPLACE FUNCTION fn_trg_dong_dot_dieu_tri()
RETURNS TRIGGER AS $$
DECLARE
    v_MaGiuong VARCHAR(10);
BEGIN
    IF NEW.KetLuan ILIKE '%khoi%' THEN
        -- Đổi trạng thái đợt điều trị sang 'DaKhoi' và cập nhật ngày kết thúc
        UPDATE DotDieuTri
        SET TrangThai = 'DaKhoi',
            NgayKetThuc = (SELECT ThoiGian::date FROM SuKienYTe WHERE MaSuKien = NEW.MaSuKien)
        WHERE MaDotDieuTri = NEW.MaDotDieuTri;

        -- Giải phóng giường bệnh đang giữ cho đợt điều trị này (nếu có)
        SELECT MaGiuong INTO v_MaGiuong FROM DotDieuTri WHERE MaDotDieuTri = NEW.MaDotDieuTri;
        IF v_MaGiuong IS NOT NULL THEN
            UPDATE GiuongBenh SET TrangThai = 'Trong' WHERE MaGiuong = v_MaGiuong;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dong_dot_dieu_tri
AFTER INSERT OR UPDATE ON LanChuaBenh
FOR EACH ROW
EXECUTE FUNCTION fn_trg_dong_dot_dieu_tri();


-- 7.4 Tự động kiểm tra và trừ số lượng tồn kho thuốc khi kê đơn
CREATE OR REPLACE FUNCTION fn_trg_tru_ton_kho_thuoc()
RETURNS TRIGGER AS $$
DECLARE
    v_TonKho INT;
BEGIN
    -- Khóa bản ghi thuốc để tránh tranh chấp khi có nhiều ca kê đơn cùng lúc
    SELECT TonKho INTO v_TonKho FROM Thuoc WHERE MaThuoc = NEW.MaThuoc FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Thuoc % khong ton tai trong kho', NEW.MaThuoc;
    END IF;

    IF v_TonKho < NEW.SoLuong THEN
        RAISE EXCEPTION 'Thuoc % khong du ton kho de ke don (hien con %, yeu cau %)',
            NEW.MaThuoc, v_TonKho, NEW.SoLuong;
    END IF;

    -- Trừ bớt tồn kho
    UPDATE Thuoc SET TonKho = TonKho - NEW.SoLuong WHERE MaThuoc = NEW.MaThuoc;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tru_ton_kho
BEFORE INSERT ON SuDungThuoc
FOR EACH ROW
EXECUTE FUNCTION fn_trg_tru_ton_kho_thuoc();


-- 7.5 Tự động cập nhật tổng tiền trong bảng HoaDon khi bảng HoaDonChiTiet thay đổi
CREATE OR REPLACE FUNCTION fn_trg_capnhat_tong_tien_hoadon()
RETURNS TRIGGER AS $$
DECLARE
    v_MaSuKien VARCHAR(50);
BEGIN
    v_MaSuKien := COALESCE(NEW.MaSuKien, OLD.MaSuKien);

    UPDATE HoaDon
    SET TongTien = (
        SELECT COALESCE(SUM(SoTien), 0)
        FROM HoaDonChiTiet
        WHERE MaSuKien = v_MaSuKien
    )
    WHERE MaSuKien = v_MaSuKien;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_capnhat_tong_tien
AFTER INSERT OR UPDATE OR DELETE ON HoaDonChiTiet
FOR EACH ROW
EXECUTE FUNCTION fn_trg_capnhat_tong_tien_hoadon();


-- =====================================================================
-- PHẦN 8: CÀI ĐẶT CÁC FUNCTION PHỤC VỤ NGHIỆP VỤ
-- =====================================================================

-- 8.1 Tìm mã đợt điều trị đang mở (chưa kết thúc) của một bệnh nhân cho bệnh cụ thể
CREATE OR REPLACE FUNCTION fn_DotDangDieuTri(p_MaBN VARCHAR, p_MaBenh VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_MaDot VARCHAR(50);
BEGIN
    SELECT dt.MaDotDieuTri INTO v_MaDot
    FROM DotDieuTri dt
    JOIN SuKienYTe se ON se.MaSuKien = dt.MaSuKienKham
    WHERE se.MaBN = p_MaBN 
      AND dt.MaBenh = p_MaBenh 
      AND dt.TrangThai = 'DangDieuTri'
    LIMIT 1;

    RETURN v_MaDot;
END;
$$ LANGUAGE plpgsql;


-- 8.2 Tính tổng thu nhập hàng tháng của một bác sĩ: Lương cơ bản + Thưởng các ca chữa khỏi
CREATE OR REPLACE FUNCTION fn_TinhLuongBacSy(p_MaBS VARCHAR, p_Thang DATE)
RETURNS NUMERIC AS $$
DECLARE
    v_LuongCoBan   NUMERIC := 0;
    v_SoDot        INT := 0;
    v_DonGiaThuong NUMERIC := 0;
    v_LuongCoSo    NUMERIC := 0;
BEGIN
    -- Lấy mức lương cơ sở cấu hình trong hệ thống
    SELECT COALESCE(GiaTri, 0) INTO v_LuongCoSo 
    FROM ThamSoHeThong 
    WHERE TenThamSo = 'LUONG_CO_SO';

    -- Tính lương cơ bản theo hệ số lương của nhân viên
    SELECT COALESCE(nv.HeSoLuong, 0) * v_LuongCoSo INTO v_LuongCoBan
    FROM NhanVienYTe nv
    WHERE nv.MaNV = p_MaBS;

    -- Đếm số đợt điều trị bác sĩ này phụ trách đã chữa khỏi trong tháng
    SELECT COUNT(*) INTO v_SoDot
    FROM DotDieuTri dt
    JOIN SuKienYTe se ON se.MaSuKien = dt.MaSuKienKham
    WHERE se.MaBS = p_MaBS 
      AND dt.TrangThai = 'DaKhoi'
      AND date_trunc('month', dt.NgayKetThuc) = date_trunc('month', p_Thang);

    -- Lấy đơn giá tiền thưởng mỗi ca chữa khỏi
    SELECT COALESCE(GiaTri, 0) INTO v_DonGiaThuong 
    FROM ThamSoHeThong 
    WHERE TenThamSo = 'THUONG_BS_HOAN_THANH';

    RETURN v_LuongCoBan + (COALESCE(v_SoDot, 0) * v_DonGiaThuong);
END;
$$ LANGUAGE plpgsql;


-- =====================================================================
-- PHẦN 9: CÀI ĐẶT CÁC VIEW TỔNG HỢP DỮ LIỆU
-- =====================================================================

-- 9.1 View đợt điều trị đầy đủ (bù đắp thông tin MaBN, MaBS đã tách khỏi DotDieuTri khi chuẩn hóa BCNF)
CREATE OR REPLACE VIEW v_DotDieuTri_ChiTiet AS
SELECT 
    dt.MaDotDieuTri,
    se.MaBN,
    bn.HoTen AS TenBenhNhan,
    se.MaBS,
    nv.HoTen AS TenBacSy,
    dt.MaBenh,
    db.TenBenh,
    dt.MucDoNang,
    dt.NgayBatDau,
    dt.NgayKetThuc,
    dt.TrangThai,
    dt.MaGiuong,
    dt.MaDotTruoc
FROM DotDieuTri dt
JOIN LanKham lk ON lk.MaSuKien = dt.MaSuKienKham
JOIN SuKienYTe se ON se.MaSuKien = lk.MaSuKien
JOIN BenhNhan bn ON bn.MaBN = se.MaBN
JOIN NhanVienYTe nv ON nv.MaNV = se.MaBS
JOIN DanhMucBenh db ON db.MaBenh = dt.MaBenh;


-- 9.2 View thống kê doanh thu theo ngày
CREATE OR REPLACE VIEW v_DoanhThu_TheoNgay AS
SELECT 
    se.ThoiGian::date AS Ngay,
    SUM(COALESCE(lk.TienKham, 0) + COALESCE(lc.TienChua, 0)) AS TienKhamChua,
    COALESCE(SUM(hd.TongTien), 0) AS TongDoanhThuHoaDon
FROM SuKienYTe se
LEFT JOIN LanKham lk ON lk.MaSuKien = se.MaSuKien
LEFT JOIN LanChuaBenh lc ON lc.MaSuKien = se.MaSuKien
LEFT JOIN HoaDon hd ON hd.MaSuKien = se.MaSuKien
GROUP BY se.ThoiGian::date;


-- =====================================================================
-- PHẦN 10: CÀI ĐẶT 6 STORED PROCEDURE (TRANSACTION XỬ LÝ NGHIỆP VỤ)
-- =====================================================================

-- 10.1 Tiếp nhận bệnh nhân đến khám, tự động tạo sự kiện và mở đợt điều trị mới (T1)
CREATE OR REPLACE PROCEDURE sp_TiepNhanKham(
    p_MaBN          VARCHAR, 
    p_MaBS          VARCHAR, 
    p_ThoiGian      TIMESTAMP,
    p_TrieuChung    TEXT, 
    p_TienKham      NUMERIC, 
    p_MaKhoa        VARCHAR,
    p_MaBenh        VARCHAR DEFAULT NULL, 
    p_MucDo         VARCHAR DEFAULT NULL, 
    p_SoLanDuKien   INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE 
    v_MaSuKien VARCHAR(50); 
    v_MaDotMo  VARCHAR(50);
BEGIN
    -- Kiểm tra tính hợp lệ của dữ liệu đầu vào
    IF NOT EXISTS (SELECT 1 FROM BenhNhan WHERE MaBN = p_MaBN) THEN
        RAISE EXCEPTION 'Benh nhan % khong ton tai tren he thong', p_MaBN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM BacSy WHERE MaNV = p_MaBS) THEN
        RAISE EXCEPTION 'Bac sy % khong hop le hoac khong ton tai', p_MaBS;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = p_MaKhoa) THEN
        RAISE EXCEPTION 'Khoa % khong ton tai', p_MaKhoa;
    END IF;

    -- Thêm sự kiện y tế khám bệnh (mã được sinh tự động bằng trigger trg_sinh_ma_sukien)
    INSERT INTO SuKienYTe(MaSuKien, MaBN, MaBS, ThoiGian, LoaiSuKien)
    VALUES (NULL, p_MaBN, p_MaBS, COALESCE(p_ThoiGian, CURRENT_TIMESTAMP), 'KHAM')
    RETURNING MaSuKien INTO v_MaSuKien;

    -- Thêm bản ghi vào bảng con LanKham
    INSERT INTO LanKham(MaSuKien, MaKhoa, TrieuChung, TienKham)
    VALUES (v_MaSuKien, p_MaKhoa, p_TrieuChung, COALESCE(p_TienKham, 0));

    -- Nếu bác sĩ chẩn đoán ra bệnh và có chỉ định điều trị
    IF p_MaBenh IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM DanhMucBenh WHERE MaBenh = p_MaBenh) THEN
            RAISE EXCEPTION 'Ma benh % khong ton tai trong danh muc benh', p_MaBenh;
        END IF;

        -- Kiểm tra xem bệnh nhân này đã có đợt điều trị bệnh này đang mở chưa
        v_MaDotMo := fn_DotDangDieuTri(p_MaBN, p_MaBenh);

        -- Nếu chưa có đợt đang mở thì mới tạo đợt điều trị mới
        IF v_MaDotMo IS NULL THEN
            INSERT INTO DotDieuTri(
                MaDotDieuTri, MaSuKienKham, MaBenh, MucDoNang,
                SoLanChuaDuKien, NgayBatDau, TrangThai
            )
            VALUES (
                'DT-' || v_MaSuKien, v_MaSuKien, p_MaBenh, p_MucDo,
                p_SoLanDuKien, COALESCE(p_ThoiGian::date, CURRENT_DATE), 'DangDieuTri'
            );
        END IF;
    END IF;

    COMMIT;
END;
$$;


-- 10.2 Ghi nhận một lần chữa bệnh, bố trí phòng, y tá hỗ trợ, kê thuốc và tính công (T2)
CREATE OR REPLACE PROCEDURE sp_GhiNhanChuaBenh(
    p_MaDotDieuTri   VARCHAR, 
    p_ThoiGian       TIMESTAMP, 
    p_MaPhong        VARCHAR,
    p_HinhThucChua   VARCHAR, 
    p_KetLuan        TEXT, 
    p_TienChua       NUMERIC,
    p_MaThuoc        VARCHAR DEFAULT NULL, 
    p_SoLuongThuoc   INT DEFAULT NULL, 
    p_DonGiaThuoc    NUMERIC DEFAULT NULL,
    p_MaLoaiCongBS   VARCHAR DEFAULT NULL, 
    p_DonGiaCongBS   NUMERIC DEFAULT NULL,
    p_MaYTa          VARCHAR DEFAULT NULL, 
    p_MaLoaiCongYT   VARCHAR DEFAULT NULL, 
    p_DonGiaCongYT   NUMERIC DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE 
    v_MaBS          VARCHAR(10); 
    v_MaBN          VARCHAR(10); 
    v_TrangThaiDot  VARCHAR(20);
    v_MaSuKien      VARCHAR(50);
BEGIN
    -- Lấy thông tin bác sĩ phụ trách và bệnh nhân từ đợt điều trị
    SELECT se.MaBS, se.MaBN, dt.TrangThai 
    INTO v_MaBS, v_MaBN, v_TrangThaiDot
    FROM DotDieuTri dt 
    JOIN SuKienYTe se ON se.MaSuKien = dt.MaSuKienKham
    WHERE dt.MaDotDieuTri = p_MaDotDieuTri;

    IF v_MaBS IS NULL THEN
        RAISE EXCEPTION 'Dot dieu tri % khong ton tai', p_MaDotDieuTri;
    END IF;

    IF v_TrangThaiDot = 'DaKhoi' THEN
        RAISE EXCEPTION 'Dot dieu tri % da ket thuc (DaKhoi), khong the ghi nhan them lan chua', p_MaDotDieuTri;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM PhongKham WHERE MaPhong = p_MaPhong) THEN
        RAISE EXCEPTION 'Phong kham % khong ton tai', p_MaPhong;
    END IF;

    -- Tạo sự kiện y tế loại 'CHUA'
    INSERT INTO SuKienYTe(MaSuKien, MaBN, MaBS, ThoiGian, LoaiSuKien)
    VALUES (NULL, v_MaBN, v_MaBS, COALESCE(p_ThoiGian, CURRENT_TIMESTAMP), 'CHUA')
    RETURNING MaSuKien INTO v_MaSuKien;

    -- Thêm chi tiết lần chữa bệnh vào bảng LanChuaBenh
    INSERT INTO LanChuaBenh(MaSuKien, MaDotDieuTri, HinhThucChua, KetLuan, TienChua, MaPhong)
    VALUES (v_MaSuKien, p_MaDotDieuTri, p_HinhThucChua, p_KetLuan, COALESCE(p_TienChua, 0), p_MaPhong);

    -- Ghi nhận công lao động của bác sĩ trực tiếp chữa bệnh
    IF p_MaLoaiCongBS IS NOT NULL THEN
        INSERT INTO SuDungNhanCong(MaSuKien, MaNV, MaLoaiCong, VaiTro, DonGiaApDung)
        VALUES (v_MaSuKien, v_MaBS, p_MaLoaiCongBS, 'Truc tiep chua benh', COALESCE(p_DonGiaCongBS, 0));
    END IF;

    -- Ghi nhận y tá tham gia phụ tá nếu có
    IF p_MaYTa IS NOT NULL AND p_MaLoaiCongYT IS NOT NULL THEN
        INSERT INTO SuDungNhanCong(MaSuKien, MaNV, MaLoaiCong, VaiTro, DonGiaApDung)
        VALUES (v_MaSuKien, p_MaYTa, p_MaLoaiCongYT, 'Ho tro chua benh', COALESCE(p_DonGiaCongYT, 0));
    END IF;

    -- Kê đơn thuốc sử dụng nếu có (trigger trg_tru_ton_kho sẽ tự động kiểm tra tồn kho)
    IF p_MaThuoc IS NOT NULL AND p_SoLuongThuoc > 0 THEN
        INSERT INTO SuDungThuoc(MaSuKien, MaThuoc, SoLuong, DonGiaApDung)
        VALUES (v_MaSuKien, p_MaThuoc, p_SoLuongThuoc, COALESCE(p_DonGiaThuoc, 0));
    END IF;

    COMMIT;
END;
$$;


-- 10.3 Xuất hóa đơn tổng hợp cho một sự kiện y tế (T3)
-- Tự động tập hợp chi phí: khám/chữa + phòng + thuốc + thiết bị + dịch vụ + công
CREATE OR REPLACE PROCEDURE sp_XuatHoaDon(p_MaSuKien VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE 
    v_TienKham    NUMERIC := 0; 
    v_TienChua    NUMERIC := 0; 
    v_TienPhong   NUMERIC := 0; 
    v_STT         INT := 0;
    v_TrangThaiTT VARCHAR(20);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SuKienYTe WHERE MaSuKien = p_MaSuKien) THEN
        RAISE EXCEPTION 'Su kien y te % khong ton tai', p_MaSuKien;
    END IF;

    -- Kiểm tra nếu hóa đơn đã thanh toán rồi thì không cho phép xuất đè
    SELECT TrangThaiTT INTO v_TrangThaiTT FROM HoaDon WHERE MaSuKien = p_MaSuKien;
    IF v_TrangThaiTT = 'DaThanhToan' THEN
        RAISE EXCEPTION 'Hoa don cua su kien % da thanh toan, khong the sua doi', p_MaSuKien;
    END IF;

    -- Tạo bản ghi hóa đơn nếu chưa có
    INSERT INTO HoaDon(MaSuKien, NgayLap, TongTien, TrangThaiTT)
    VALUES (p_MaSuKien, CURRENT_TIMESTAMP, 0, 'ChuaThanhToan')
    ON CONFLICT (MaSuKien) DO NOTHING;

    -- Xóa các dòng chi tiết cũ nếu tính lại để tránh trùng lặp khóa phức hợp (MaSuKien, SoDong)
    DELETE FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;

    -- 1. Tiền khám bệnh
    SELECT COALESCE(TienKham, 0) INTO v_TienKham FROM LanKham WHERE MaSuKien = p_MaSuKien;
    IF v_TienKham > 0 THEN
        v_STT := v_STT + 1;
        INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
        VALUES (p_MaSuKien, v_STT, 'Tien kham benh', v_TienKham);
    END IF;

    -- 2. Tiền chữa bệnh và tiền sử dụng phòng
    SELECT COALESCE(lc.TienChua, 0), COALESCE(pk.DonGiaSuDung, 0)
    INTO v_TienChua, v_TienPhong
    FROM LanChuaBenh lc 
    LEFT JOIN PhongKham pk ON pk.MaPhong = lc.MaPhong
    WHERE lc.MaSuKien = p_MaSuKien;

    IF v_TienChua > 0 THEN
        v_STT := v_STT + 1;
        INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
        VALUES (p_MaSuKien, v_STT, 'Tien chua benh', v_TienChua);
    END IF;

    IF v_TienPhong > 0 THEN
        v_STT := v_STT + 1;
        INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
        VALUES (p_MaSuKien, v_STT, 'Tien su dung phong', v_TienPhong);
    END IF;

    -- 3. Chi phí tiền thuốc kê đơn
    INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
    SELECT 
        p_MaSuKien, 
        v_STT + row_number() OVER (), 
        'Thuoc: ' || t.TenThuoc || ' (SL: ' || sd.SoLuong || ')', 
        sd.SoLuong * sd.DonGiaApDung
    FROM SuDungThuoc sd 
    JOIN Thuoc t ON t.MaThuoc = sd.MaThuoc
    WHERE sd.MaSuKien = p_MaSuKien;

    SELECT COALESCE(MAX(SoDong), v_STT) INTO v_STT FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;

    -- 4. Chi phí sử dụng thiết bị y tế (bổ sung đầy đủ theo đúng mô hình phân tích)
    INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
    SELECT 
        p_MaSuKien, 
        v_STT + row_number() OVER (), 
        'Thiet bi: ' || tb.TenThietBi || ' (SL: ' || stb.SoLuong || ')', 
        stb.SoLuong * stb.DonGiaApDung
    FROM SuDungThietBi stb 
    JOIN ThietBi tb ON tb.MaThietBi = stb.MaThietBi
    WHERE stb.MaSuKien = p_MaSuKien;

    SELECT COALESCE(MAX(SoDong), v_STT) INTO v_STT FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;

    -- 5. Chi phí dịch vụ y tế đi kèm (xét nghiệm, siêu âm...)
    INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
    SELECT 
        p_MaSuKien, 
        v_STT + row_number() OVER (), 
        'Dich vu: ' || dv.TenDV || ' (SL: ' || sdv.SoLuong || ')', 
        sdv.SoLuong * sdv.DonGiaApDung
    FROM SuDungDichVu sdv 
    JOIN DichVuYTe dv ON dv.MaDV = sdv.MaDV
    WHERE sdv.MaSuKien = p_MaSuKien;

    SELECT COALESCE(MAX(SoDong), v_STT) INTO v_STT FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;

    -- 6. Chi phí nhân công bác sĩ và y tá hỗ trợ
    INSERT INTO HoaDonChiTiet(MaSuKien, SoDong, MoTaKhoanMuc, SoTien)
    SELECT 
        p_MaSuKien, 
        v_STT + row_number() OVER (), 
        'Cong: ' || lnc.TenLoaiCong || ' - ' || nv.HoTen, 
        snc.DonGiaApDung
    FROM SuDungNhanCong snc 
    JOIN LoaiNhanCong lnc ON lnc.MaLoaiCong = snc.MaLoaiCong
    JOIN NhanVienYTe nv ON nv.MaNV = snc.MaNV
    WHERE snc.MaSuKien = p_MaSuKien;

    -- Trigger trg_capnhat_tong_tien sẽ tự động tính tổng tiền vào bảng HoaDon
    COMMIT;
END;
$$;


-- 10.4 Nhập thêm thuốc vào kho phòng khám (T4)
CREATE OR REPLACE PROCEDURE sp_NhapKhoThuoc(
    p_MaThuoc    VARCHAR, 
    p_SoLuong    INT, 
    p_DonGiaMoi  NUMERIC DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_SoLuong <= 0 THEN
        RAISE EXCEPTION 'So luong nhap kho phai lon hon 0';
    END IF;

    IF p_DonGiaMoi IS NOT NULL AND p_DonGiaMoi < 0 THEN
        RAISE EXCEPTION 'Don gia thuoc moi khong duoc am';
    END IF;

    UPDATE Thuoc
    SET TonKho = TonKho + p_SoLuong,
        DonGia = COALESCE(p_DonGiaMoi, DonGia)
    WHERE MaThuoc = p_MaThuoc;

    IF NOT FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION 'Khong tim thay thuoc % trong he thong de nhap kho', p_MaThuoc;
    END IF;

    COMMIT;
END;
$$;


-- 10.5 Hủy một lần khám nhập nhầm - Minh họa ROLLBACK tường minh khi vi phạm nghiệp vụ (T5)
CREATE OR REPLACE PROCEDURE sp_HuyLanKham(p_MaSuKien VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE 
    v_SoDotLienQuan INT;
BEGIN
    -- Nếu lần khám này đã mở đợt điều trị thì không được xóa thẳng, phải hủy đợt trước
    SELECT COUNT(*) INTO v_SoDotLienQuan
    FROM DotDieuTri 
    WHERE MaSuKienKham = p_MaSuKien;

    IF v_SoDotLienQuan > 0 THEN
        ROLLBACK;
        RAISE EXCEPTION 'Khong the huy: lan kham % da mo % dot dieu tri, can huy dot dieu tri truoc',
            p_MaSuKien, v_SoDotLienQuan;
    END IF;

    -- Dọn dẹp sạch các bảng con phụ thuộc nếu có phát sinh chi phí trước đó
    DELETE FROM HoaDonChiTiet WHERE MaSuKien = p_MaSuKien;
    DELETE FROM HoaDon WHERE MaSuKien = p_MaSuKien;
    DELETE FROM SuDungThuoc WHERE MaSuKien = p_MaSuKien;
    DELETE FROM SuDungThietBi WHERE MaSuKien = p_MaSuKien;
    DELETE FROM SuDungDichVu WHERE MaSuKien = p_MaSuKien;
    DELETE FROM SuDungNhanCong WHERE MaSuKien = p_MaSuKien;
    DELETE FROM LanKham WHERE MaSuKien = p_MaSuKien;
    DELETE FROM SuKienYTe WHERE MaSuKien = p_MaSuKien;

    COMMIT;
END;
$$;


-- 10.6 Quyết toán và phát lương hàng tháng cho nhân viên y tế (T6)
CREATE OR REPLACE PROCEDURE sp_TraLuong(p_MaNV VARCHAR, p_Thang DATE)
LANGUAGE plpgsql AS $$
DECLARE 
    v_LoaiNV          VARCHAR(10); 
    v_LuongCoBan      NUMERIC := 0; 
    v_Thuong          NUMERIC := 0; 
    v_Tong            NUMERIC := 0;
    v_LuongCoSo       NUMERIC := 0;
    v_ThuongYTaDonGia NUMERIC := 0;
BEGIN
    -- Lấy thông tin nhân sự
    SELECT LoaiNV, HeSoLuong INTO v_LoaiNV, v_LuongCoBan
    FROM NhanVienYTe 
    WHERE MaNV = p_MaNV;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nhan vien y te % khong ton tai', p_MaNV;
    END IF;

    -- Lấy mức lương cơ sở
    SELECT COALESCE(GiaTri, 0) INTO v_LuongCoSo 
    FROM ThamSoHeThong 
    WHERE TenThamSo = 'LUONG_CO_SO';

    v_LuongCoBan := v_LuongCoBan * v_LuongCoSo;

    -- Nếu là Bác sĩ: Thưởng theo hiệu suất số ca chữa khỏi trong tháng
    IF v_LoaiNV = 'BACSY' THEN
        v_Tong := fn_TinhLuongBacSy(p_MaNV, p_Thang);
        v_Thuong := v_Tong - v_LuongCoBan;
    ELSE
        -- Nếu là Y tá: Thưởng tính theo số lượt tham gia hỗ trợ khám chữa trong tháng
        SELECT COALESCE(GiaTri, 0) INTO v_ThuongYTaDonGia 
        FROM ThamSoHeThong 
        WHERE TenThamSo = 'THUONG_YTA_HOTRO';

        SELECT COUNT(snc.MaSuKien) * v_ThuongYTaDonGia INTO v_Thuong
        FROM SuDungNhanCong snc 
        JOIN SuKienYTe se ON se.MaSuKien = snc.MaSuKien
        WHERE snc.MaNV = p_MaNV 
          AND date_trunc('month', se.ThoiGian) = date_trunc('month', p_Thang);

        v_Tong := v_LuongCoBan + COALESCE(v_Thuong, 0);
    END IF;

    -- Lưu vào bảng lương, nếu tháng này đã chạy rồi thì cập nhật lại số liệu mới
    INSERT INTO Luong(MaLuong, MaNV, Thang, NgayNhanLuong, LuongCoBan, TienThuong, TongLuong, GhiChu)
    VALUES (
        'LG-' || p_MaNV || '-' || to_char(p_Thang, 'YYYYMM'), 
        p_MaNV, 
        p_Thang, 
        CURRENT_DATE,
        v_LuongCoBan, 
        COALESCE(v_Thuong, 0), 
        v_Tong,
        'Quyet toan luong thang ' || to_char(p_Thang, 'MM/YYYY')
    )
    ON CONFLICT (MaNV, Thang) DO UPDATE
    SET LuongCoBan    = EXCLUDED.LuongCoBan,
        TienThuong    = EXCLUDED.TienThuong,
        TongLuong     = EXCLUDED.TongLuong,
        NgayNhanLuong = EXCLUDED.NgayNhanLuong,
        GhiChu        = EXCLUDED.GhiChu;

    COMMIT;
END;
$$;


-- =====================================================================
-- PHẦN 11: NẠP CẤU HÌNH THAM SỐ HỆ THỐNG MẶC ĐỊNH
-- =====================================================================

INSERT INTO ThamSoHeThong (TenThamSo, GiaTri) VALUES
('LUONG_CO_SO', 1800000),             -- Lương cơ sở áp dụng tính lương cơ bản
('THUONG_BS_HOAN_THANH', 200000),     -- Thưởng cho bác sĩ trên mỗi đợt điều trị khỏi bệnh
('THUONG_YTA_HOTRO', 50000)           -- Thưởng cho y tá trên mỗi lượt hỗ trợ ca chữa bệnh
ON CONFLICT (TenThamSo) DO UPDATE SET GiaTri = EXCLUDED.GiaTri;


-- =====================================================================
-- PHẦN 12: CHÈN DỮ LIỆU MẪU MÔ PHỎNG NGHIỆP VỤ THỰC TẾ (SEED DATA)
-- Dữ liệu mô phỏng 100% giống thật: Bệnh nhân thật, khoa phòng chuẩn y tế,
-- danh mục bệnh ICD-10, thuốc và hãng dược uy tín, các ca khám chữa bệnh,
-- ca điều trị dài ngày, ca tái phát đệ quy và hóa đơn thanh toán chi tiết.
-- =====================================================================

-- 12.1 Danh mục các chuyên khoa
INSERT INTO Khoa (MaKhoa, TenKhoa, MoTa) VALUES
('KHOA_NOI', 'Khoa Nội tổng hợp', 'Khám, chẩn đoán và điều trị bệnh lý tim mạch, hô hấp, tiêu hóa, nội tiết'),
('KHOA_NGOAI', 'Khoa Ngoại tổng quát', 'Tiểu phẫu thuật, xử lý chấn thương phần mềm, vết thương ngoài da'),
('KHOA_NHI', 'Khoa Nhi', 'Chăm sóc sức khỏe, khám và điều trị các bệnh lý thường gặp ở trẻ nhỏ'),
('KHOA_TMH', 'Khoa Tai Mũi Họng', 'Chẩn đoán nội soi, điều trị viêm xoang, viêm tai, viêm họng, viêm amidan'),
('KHOA_RHM', 'Khoa Răng Hàm Mặt', 'Nha khoa tổng quát, điều trị tủy răng, nhổ răng bệnh lý, lấy cao răng');

-- 12.2 Danh mục loại nhân công y tế
INSERT INTO LoaiNhanCong (MaLoaiCong, TenLoaiCong, DonGiaMacDinh) VALUES
('LC01', 'Công khám bệnh chuyên khoa tiêu chuẩn', 150000),
('LC02', 'Công khám bệnh theo yêu cầu / ngoài giờ', 250000),
('LC03', 'Công trực tiếp thực hiện điều trị / thủ thuật', 100000),
('LC04', 'Công y tá phụ tá thủ thuật / chăm sóc', 50000),
('LC05', 'Công điều dưỡng tiêm truyền / theo dõi phòng', 30000);

-- 12.3 Hồ sơ bệnh nhân thực tế
INSERT INTO BenhNhan (MaBN, HoTen, GioiTinh, NgaySinh, SDT, DiaChi, SoCCCD, NgayDangKy) VALUES
('BN001', 'Nguyễn Thị Mai Hương', 'F', '1988-04-15', '0912345688', 'Số 25 ngõ 12 Đặng Tiến Đông, Đống Đa, Hà Nội', '001188001234', '2026-08-10'),
('BN002', 'Trần Văn Tuấn', 'M', '1975-11-20', '0988776655', 'Căn 1204 Tòa R2 Royal City, Thanh Xuân, Hà Nội', '001075005678', '2026-08-15'),
('BN003', 'Lê Hoàng Long', 'M', '2018-06-02', '0976543210', 'Số 8 ngách 42 Liễu Giai, Ba Đình, Hà Nội', '001218009876', '2026-08-20'),
('BN004', 'Phạm Thu Thảo', 'F', '1995-09-12', '0904123987', 'Số 56 Phố Huế, Hàng Bài, Hoàn Kiếm, Hà Nội', '001195004321', '2026-08-22'),
('BN005', 'Vũ Đức Thắng', 'M', '1968-03-08', '0936112233', 'Khu đô thị Mỗ Lao, Hà Đông, Hà Nội', '001068007788', '2026-08-25'),
('BN006', 'Đỗ Hồng Nhung', 'F', '2001-12-05', '0868998877', 'Số 102 Cầu Giấy, Quan Hoa, Cầu Giấy, Hà Nội', '001301002244', '2026-09-01'),
('BN007', 'Hoàng Minh Trí', 'M', '1982-07-19', '0945667788', 'Số 18 Lạc Long Quân, Tây Hồ, Hà Nội', '001082003355', '2026-09-05'),
('BN008', 'Ngô Bảo Châu', 'F', '2019-10-10', '0915223344', 'Số 45 Nguyễn Trãi, Thanh Xuân, Hà Nội', '001219006677', '2026-09-10');

-- 12.4 Danh mục bệnh y khoa (chuẩn mã ICD-10 thông dụng)
INSERT INTO DanhMucBenh (MaBenh, TenBenh, NhomBenh, MoTa) VALUES
('BENH01', 'Tăng huyết áp nguyên phát', 'Tim mạch', 'Huyết áp động mạch tăng cao mạn tính vô căn'),
('BENH02', 'Viêm loét dạ dày tá tràng', 'Tiêu hóa', 'Tổn thương viêm trợt hoặc loét niêm mạc đường tiêu hóa trên'),
('BENH03', 'Viêm phế quản cấp ở trẻ em', 'Hô hấp', 'Nhiễm trùng cấp tính đường hô hấp dưới gây ho đờm, khò khè'),
('BENH04', 'Viêm amidan cấp mủ', 'Tai Mũi Họng', 'Amidan khẩu cái viêm tấy đỏ có giả mạc mủ bề mặt'),
('BENH05', 'Viêm tủy răng không hồi phục', 'Răng Hàm Mặt', 'Tổn thương mô tủy răng do sâu răng tiến triển, đau buốt lan tỏa'),
('BENH06', 'Đái tháo đường týp 2', 'Nội tiết', 'Rối loạn chuyển hóa đường đặc trưng bởi tăng đường huyết đói'),
('BENH07', 'Thoái hóa cột sống thắt lưng', 'Cơ xương khớp', 'Thoái hóa sụn khớp và đĩa đệm vùng thắt lưng gây đau mỏi'),
('BENH08', 'Viêm xoang hàm mạn tính', 'Tai Mũi Họng', 'Viêm niêm mạc xoang hàm kéo dài trên 12 tuần kèm nghẹt mũi');

-- 12.5 Kho thuốc tân dược
INSERT INTO Thuoc (MaThuoc, TenThuoc, DonViTinh, DonGia, HangSX, TonKho) VALUES
('TH001', 'Amlodipin 5mg', 'Viên', 3500, 'Dược Hậu Giang (DHG)', 500),
('TH002', 'Nexium 40mg (Esomeprazol)', 'Viên', 24000, 'AstraZeneca', 300),
('TH003', 'Augmentin 1g', 'Viên', 18500, 'GlaxoSmithKline (GSK)', 400),
('TH004', 'Klamentin 500mg/62.5mg', 'Gói', 12000, 'Dược Hậu Giang (DHG)', 250),
('TH005', 'Panadol Extra đỏ', 'Viên', 2000, 'GSK', 1000),
('TH006', 'Rodogyl 750.000 UI', 'Viên', 7500, 'Sanofi Aventis', 350),
('TH007', 'Glucophage 850mg', 'Viên', 4200, 'Merck KGaA', 600),
('TH008', 'Mobic 7.5mg (Meloxicam)', 'Viên', 14000, 'Boehringer Ingelheim', 300),
('TH009', 'Nước muối sinh lý NaCl 0.9% 500ml', 'Chai', 10000, 'B.Braun', 200),
('TH010', 'Thuốc xịt mũi Otrivin 0.1%', 'Lọ', 55000, 'Novartis Consumer Health', 150);

-- 12.6 Danh mục thiết bị y tế kỹ thuật
INSERT INTO ThietBi (MaThietBi, TenThietBi, DonGiaSuDung) VALUES
('TB001', 'Máy siêu âm màu Doppler 4D Voluson S8', 200000),
('TB002', 'Máy điện tim vi tính 6 cần Fukuda Denshi', 80000),
('TB003', 'Hệ thống nội soi Tai Mũi Họng ống mềm Pentax', 150000),
('TB004', 'Ghế máy nha khoa đa năng Anthos A3', 100000),
('TB005', 'Máy chụp X-Quang kỹ thuật số DR Carestream', 180000),
('TB006', 'Máy hút dịch khí dung phế quản Medela', 40000);

-- 12.7 Danh mục dịch vụ cận lâm sàng và kỹ thuật y tế
INSERT INTO DichVuYTe (MaDV, TenDV, DonGia) VALUES
('DV001', 'Tổng phân tích tế bào máu ngoại vi (18 thông số)', 120000),
('DV002', 'Định lượng Glucose máu tĩnh mạch', 45000),
('DV003', 'Nội soi Tai Mũi Họng chẩn đoán', 180000),
('DV004', 'Chụp X-Quang ngực thẳng kỹ thuật số', 150000),
('DV005', 'Lấy cao răng và đánh bóng hai hàm', 150000),
('DV006', 'Khí dung thuốc mũi họng phế quản', 60000);

-- 12.8 Nhân sự y tế (Bác sĩ và Y tá điều dưỡng)
INSERT INTO NhanVienYTe (MaNV, HoTen, GioiTinh, NgaySinh, SDT, MaKhoa, HeSoLuong, NgayVaoLam, LoaiNV) VALUES
('NV_BS01', 'TS.BS Nguyễn Khắc Hưng', 'M', '1978-02-14', '0903214567', 'KHOA_NOI', 4.65, '2012-05-01', 'BACSY'),
('NV_BS02', 'ThS.BS Trần Thanh Hằng', 'F', '1984-06-25', '0914556677', 'KHOA_NHI', 3.99, '2015-09-01', 'BACSY'),
('NV_BS03', 'BSCKI Đặng Quốc Tuấn', 'M', '1980-10-18', '0982334455', 'KHOA_TMH', 4.32, '2014-03-15', 'BACSY'),
('NV_BS04', 'ThS.BS Lê Mai Phương', 'F', '1989-11-04', '0934667788', 'KHOA_RHM', 3.66, '2018-07-01', 'BACSY'),
('NV_BS05', 'BSCKII Bùi Thế Anh', 'M', '1976-08-30', '0904889900', 'KHOA_NGOAI', 4.98, '2010-01-10', 'BACSY'),
('NV_YT01', 'CNĐD Hoàng Thị Lan', 'F', '1993-03-21', '0978112233', 'KHOA_NOI', 2.67, '2017-04-01', 'YTA'),
('NV_YT02', 'ĐD Đỗ Thị Thúy', 'F', '1996-09-15', '0969223344', 'KHOA_NHI', 2.34, '2019-10-15', 'YTA'),
('NV_YT03', 'ĐD Vũ Văn Nam', 'M', '1994-12-08', '0984334455', 'KHOA_TMH', 2.45, '2018-06-01', 'YTA');

INSERT INTO BacSy (MaNV, Email, ChuyenMon) VALUES
('NV_BS01', 'bs.khachung@phongkham.vn', 'Nội Tim mạch - Chuyển hóa'),
('NV_BS02', 'bs.thanhhang@phongkham.vn', 'Nhi khoa tổng hợp & Hô hấp'),
('NV_BS03', 'bs.quoctuan@phongkham.vn', 'Nội soi phẫu thuật Tai Mũi Họng'),
('NV_BS04', 'bs.maiphuong@phongkham.vn', 'Nha khoa phục hình & Nội nha'),
('NV_BS05', 'bs.theanh@phongkham.vn', 'Ngoại Tiêu hóa - Gan mật');

INSERT INTO YTa (MaNV, ChungChiHanhNghe) VALUES
('NV_YT01', '001234/HNO-CCHN (Điều dưỡng đa khoa)'),
('NV_YT02', '005678/HNO-CCHN (Điều dưỡng nhi)'),
('NV_YT03', '007890/HNO-CCHN (Thủ thuật ngoại khoa)');

-- 12.9 Phòng khám và giường bệnh
INSERT INTO PhongKham (MaPhong, TenPhong, ChucNang, MaKhoa, DonGiaSuDung) VALUES
('PK101', 'Phòng Khám Nội Tim mạch', 'Khám lâm sàng nội khoa và tim mạch', 'KHOA_NOI', 0),
('PK102', 'Phòng Khám Nhi tổng hợp', 'Tiếp đón và khám chữa bệnh nhi', 'KHOA_NHI', 0),
('PK103', 'Phòng Khám & Tiểu thủ thuật TMH', 'Khám, nội soi và làm thủ thuật TMH', 'KHOA_TMH', 50000),
('PK104', 'Phòng Khám Răng Hàm Mặt', 'Khám, chữa tủy và nha khoa thẩm mỹ', 'KHOA_RHM', 60000),
('PK201', 'Phòng Lưu bệnh Nội khoa', 'Lưu viện theo dõi điều trị ngắn ngày', 'KHOA_NOI', 100000),
('PK202', 'Phòng Lưu bệnh Nhi khoa', 'Theo dõi sốt cao, truyền dịch bệnh nhi', 'KHOA_NHI', 100000);

INSERT INTO GiuongBenh (MaGiuong, MaPhong, TrangThai, DonGiaNgay) VALUES
('GB201_01', 'PK201', 'DangDieuTri', 150000),
('GB201_02', 'PK201', 'Trong', 150000),
('GB201_03', 'PK201', 'Trong', 150000),
('GB202_01', 'PK202', 'Trong', 180000),
('GB202_02', 'PK202', 'Trong', 180000),
('GB202_03', 'PK202', 'BaoTri', 180000);

-- 12.10 Sự kiện y tế khám và chữa bệnh
INSERT INTO SuKienYTe (MaSuKien, MaBN, MaBS, ThoiGian, LoaiSuKien) VALUES
('NOI-BS01-K-20260710-0001', 'BN004', 'NV_BS01', '2026-07-10 08:30:00', 'KHAM'),
('NOI-BS01-C-20260725-0002', 'BN004', 'NV_BS01', '2026-07-25 09:15:00', 'CHUA'),
('NHI-BS02-K-20260820-0003', 'BN003', 'NV_BS02', '2026-08-20 08:45:00', 'KHAM'),
('NHI-BS02-C-20260822-0004', 'BN003', 'NV_BS02', '2026-08-22 09:00:00', 'CHUA'),
('NHI-BS02-C-20260825-0005', 'BN003', 'NV_BS02', '2026-08-25 09:30:00', 'CHUA'),
('NOI-BS01-K-20260901-0006', 'BN002', 'NV_BS01', '2026-09-01 08:00:00', 'KHAM'),
('NOI-BS01-C-20260903-0007', 'BN002', 'NV_BS01', '2026-09-03 08:30:00', 'CHUA'),
('NOI-BS01-K-20260905-0008', 'BN004', 'NV_BS01', '2026-09-05 08:30:00', 'KHAM'),
('TMH-BS03-K-20260910-0009', 'BN001', 'NV_BS03', '2026-09-10 09:00:00', 'KHAM'),
('TMH-BS03-C-20260912-0010', 'BN001', 'NV_BS03', '2026-09-12 09:30:00', 'CHUA'),
('RHM-BS04-K-20260915-0011', 'BN005', 'NV_BS04', '2026-09-15 14:00:00', 'KHAM'),
('RHM-BS04-C-20260918-0012', 'BN005', 'NV_BS04', '2026-09-18 14:30:00', 'CHUA'),
('NOI-BS01-K-20260920-0013', 'BN007', 'NV_BS01', '2026-09-20 10:00:00', 'KHAM');

-- 12.11 Thông tin chi tiết các lần khám
INSERT INTO LanKham (MaSuKien, MaKhoa, TrieuChung, TienKham) VALUES
('NOI-BS01-K-20260710-0001', 'KHOA_NOI', 'Đau âm ỉ vùng thượng vị, ợ hơi, cồn cào lúc đói', 150000),
('NHI-BS02-K-20260820-0003', 'KHOA_NHI', 'Trẻ sốt cao 38.8 độ C, ho cơn, thở khò khè', 150000),
('NOI-BS01-K-20260901-0006', 'KHOA_NOI', 'Chóng mặt, tức ngực trái, đo huyết áp 165/100 mmHg', 150000),
('NOI-BS01-K-20260905-0008', 'KHOA_NOI', 'Đau rát thượng vị tái phát dữ dội sau ăn đồ chua cay', 150000),
('TMH-BS03-K-20260910-0009', 'KHOA_TMH', 'Nuốt vướng, đau rát họng nhiều, sốt nhẹ 38 độ', 150000),
('RHM-BS04-K-20260915-0011', 'KHOA_RHM', 'Răng hàm dưới đau buốt dữ dội từng cơn lan lên thái dương', 150000),
('NOI-BS01-K-20260920-0013', 'KHOA_NOI', 'Khám sức khỏe tổng quát định kỳ, kiểm tra đường huyết', 200000);

-- 12.12 Đợt điều trị (có đợt đã khỏi, đợt đang điều trị, và ca tái phát MaDotTruoc)
INSERT INTO DotDieuTri (MaDotDieuTri, MaSuKienKham, MaBenh, MucDoNang, SoLanChuaDuKien, NgayBatDau, NgayKetThuc, TrangThai, MaGiuong, MaDotTruoc) VALUES
('DT_20260710_001', 'NOI-BS01-K-20260710-0001', 'BENH02', 'Vua', 2, '2026-07-10', '2026-07-25', 'DaKhoi', NULL, NULL),
('DT_20260820_001', 'NHI-BS02-K-20260820-0003', 'BENH03', 'Nhe', 2, '2026-08-20', '2026-08-25', 'DaKhoi', 'GB202_01', NULL),
('DT_20260901_001', 'NOI-BS01-K-20260901-0006', 'BENH01', 'Nang', 3, '2026-09-01', NULL, 'DangDieuTri', 'GB201_01', NULL),
('DT_20260905_001', 'NOI-BS01-K-20260905-0008', 'BENH02', 'Vua', 2, '2026-09-05', NULL, 'DangDieuTri', NULL, 'DT_20260710_001'),
('DT_20260910_001', 'TMH-BS03-K-20260910-0009', 'BENH04', 'Vua', 2, '2026-09-10', NULL, 'DangDieuTri', NULL, NULL),
('DT_20260915_001', 'RHM-BS04-K-20260915-0011', 'BENH05', 'Nhe', 2, '2026-09-15', NULL, 'DangDieuTri', NULL, NULL);

-- 12.13 Chi tiết các lần chữa bệnh
INSERT INTO LanChuaBenh (MaSuKien, MaDotDieuTri, HinhThucChua, KetLuan, TienChua, MaPhong) VALUES
('NOI-BS01-C-20260725-0002', 'DT_20260710_001', 'Nội soi can thiệp & cấp thuốc', 'Ổ loét hành tá tràng đã thành sẹo tốt, niêm mạc ổn định, đã khỏi bệnh', 150000, 'PK201'),
('NHI-BS02-C-20260822-0004', 'DT_20260820_001', 'Khí dung phế quản & kháng viêm', 'Trẻ đỡ ho, nhiệt độ giảm còn 37.5 độ C, tiếp tục dùng thuốc', 100000, 'PK102'),
('NHI-BS02-C-20260825-0005', 'DT_20260820_001', 'Khám đánh giá đáp ứng phế quản', 'Phổi thông khí đều, hết khò khè, trẻ ăn ngủ tốt, đã khỏi hoàn toàn', 80000, 'PK102'),
('NOI-BS01-C-20260903-0007', 'DT_20260901_001', 'Điều chỉnh thuốc hạ áp & đo Holter', 'Huyết áp giảm về 138/85 mmHg, người đỡ mệt, tiếp tục phác đồ', 120000, 'PK201'),
('TMH-BS03-C-20260912-0010', 'DT_20260910_001', 'Hút mủ amidan & sát khuẩn họng', 'Amidan bớt sưng đỏ, giả mạc tan dần, đỡ đau nuốt', 100000, 'PK103'),
('RHM-BS04-C-20260918-0012', 'DT_20260915_001', 'Lấy tủy buồng, làm sạch ống tủy', 'Đã đặt thuốc diệt tủy răng 46, hết đau nhức, hẹn trám bít ống tủy', 150000, 'PK104');

-- 12.14 Kê đơn thuốc (Trigger trg_tru_ton_kho tự động trừ tồn kho)
INSERT INTO SuDungThuoc (MaSuKien, MaThuoc, SoLuong, DonGiaApDung) VALUES
('NOI-BS01-K-20260710-0001', 'TH002', 14, 24000),
('NHI-BS02-K-20260820-0003', 'TH004', 10, 12000),
('NHI-BS02-K-20260820-0003', 'TH005', 10, 2000),
('NOI-BS01-K-20260901-0006', 'TH001', 30, 3500),
('NOI-BS01-K-20260905-0008', 'TH002', 14, 24000),
('TMH-BS03-K-20260910-0009', 'TH003', 14, 18500),
('TMH-BS03-K-20260910-0009', 'TH005', 10, 2000),
('TMH-BS03-C-20260912-0010', 'TH010', 1, 55000),
('RHM-BS04-K-20260915-0011', 'TH006', 20, 7500),
('RHM-BS04-K-20260915-0011', 'TH005', 10, 2000);

-- 12.15 Sử dụng máy móc, thiết bị y tế
INSERT INTO SuDungThietBi (MaSuKien, MaThietBi, SoLuong, DonGiaApDung) VALUES
('NOI-BS01-K-20260710-0001', 'TB001', 1, 200000),
('NHI-BS02-C-20260822-0004', 'TB006', 1, 40000),
('NOI-BS01-K-20260901-0006', 'TB002', 1, 80000),
('TMH-BS03-K-20260910-0009', 'TB003', 1, 150000),
('RHM-BS04-K-20260915-0011', 'TB004', 1, 100000),
('NOI-BS01-K-20260920-0013', 'TB002', 1, 80000);

-- 12.16 Thực hiện dịch vụ kỹ thuật cận lâm sàng
INSERT INTO SuDungDichVu (MaSuKien, MaDV, SoLuong, DonGiaApDung) VALUES
('NOI-BS01-K-20260710-0001', 'DV001', 1, 120000),
('NHI-BS02-C-20260822-0004', 'DV006', 1, 60000),
('NOI-BS01-K-20260901-0006', 'DV001', 1, 120000),
('NOI-BS01-K-20260901-0006', 'DV002', 1, 45000),
('TMH-BS03-K-20260910-0009', 'DV003', 1, 180000),
('RHM-BS04-K-20260915-0011', 'DV005', 1, 150000),
('NOI-BS01-K-20260920-0013', 'DV001', 1, 120000),
('NOI-BS01-K-20260920-0013', 'DV002', 1, 45000);

-- 12.17 Ghi nhận công lao động y tế
INSERT INTO SuDungNhanCong (MaSuKien, MaNV, MaLoaiCong, VaiTro, DonGiaApDung) VALUES
('NOI-BS01-K-20260710-0001', 'NV_BS01', 'LC01', 'Bác sĩ khám chính', 150000),
('NOI-BS01-C-20260725-0002', 'NV_BS01', 'LC03', 'Bác sĩ trực tiếp điều trị nội soi', 100000),
('NHI-BS02-K-20260820-0003', 'NV_BS02', 'LC01', 'Bác sĩ khám nhi', 150000),
('NHI-BS02-C-20260822-0004', 'NV_BS02', 'LC03', 'Bác sĩ điều trị phế quản', 100000),
('NHI-BS02-C-20260822-0004', 'NV_YT02', 'LC04', 'Y tá phụ tá khí dung', 50000),
('NHI-BS02-C-20260825-0005', 'NV_BS02', 'LC03', 'Bác sĩ khám xuất viện', 100000),
('NOI-BS01-K-20260901-0006', 'NV_BS01', 'LC01', 'Bác sĩ khám tim mạch', 150000),
('NOI-BS01-C-20260903-0007', 'NV_BS01', 'LC03', 'Bác sĩ điều trị hạ áp', 100000),
('NOI-BS01-C-20260903-0007', 'NV_YT01', 'LC05', 'Điều dưỡng theo dõi buồng bệnh', 30000),
('NOI-BS01-K-20260905-0008', 'NV_BS01', 'LC02', 'Bác sĩ khám tiêu hóa ngoài giờ', 250000),
('TMH-BS03-K-20260910-0009', 'NV_BS03', 'LC01', 'Bác sĩ khám Tai Mũi Họng', 150000),
('TMH-BS03-C-20260912-0010', 'NV_BS03', 'LC03', 'Bác sĩ thủ thuật hút mủ', 100000),
('TMH-BS03-C-20260912-0010', 'NV_YT03', 'LC04', 'Y tá phụ tá thủ thuật TMH', 50000),
('RHM-BS04-K-20260915-0011', 'NV_BS04', 'LC01', 'Bác sĩ khám Răng Hàm Mặt', 150000),
('RHM-BS04-C-20260918-0012', 'NV_BS04', 'LC03', 'Bác sĩ điều trị tủy răng', 100000),
('NOI-BS01-K-20260920-0013', 'NV_BS01', 'LC02', 'Bác sĩ khám tổng quát', 250000);

-- 12.18 Hóa đơn và chi tiết hóa đơn (Trigger trg_capnhat_tong_tien tự động tính TongTien)
INSERT INTO HoaDon (MaSuKien, NgayLap, TongTien, TrangThaiTT) VALUES
('NOI-BS01-K-20260710-0001', '2026-07-10 09:30:00', 0, 'DaThanhToan'),
('NOI-BS01-C-20260725-0002', '2026-07-25 10:00:00', 0, 'DaThanhToan'),
('NHI-BS02-K-20260820-0003', '2026-08-20 09:30:00', 0, 'DaThanhToan'),
('NHI-BS02-C-20260822-0004', '2026-08-22 10:00:00', 0, 'DaThanhToan'),
('NHI-BS02-C-20260825-0005', '2026-08-25 10:30:00', 0, 'DaThanhToan'),
('NOI-BS01-K-20260901-0006', '2026-09-01 09:15:00', 0, 'DaThanhToan'),
('NOI-BS01-C-20260903-0007', '2026-09-03 09:45:00', 0, 'DaThanhToan'),
('NOI-BS01-K-20260905-0008', '2026-09-05 09:30:00', 0, 'DaThanhToan'),
('TMH-BS03-K-20260910-0009', '2026-09-10 10:00:00', 0, 'DaThanhToan'),
('TMH-BS03-C-20260912-0010', '2026-09-12 10:30:00', 0, 'DaThanhToan'),
('RHM-BS04-K-20260915-0011', '2026-09-15 15:00:00', 0, 'DaThanhToan'),
('RHM-BS04-C-20260918-0012', '2026-09-18 15:30:00', 0, 'ChuaThanhToan'),
('NOI-BS01-K-20260920-0013', '2026-09-20 11:00:00', 0, 'DaThanhToan');

INSERT INTO HoaDonChiTiet (MaSuKien, SoDong, MoTaKhoanMuc, SoTien) VALUES
-- Hóa đơn khám tiêu hóa BN004 (10/07/2026)
('NOI-BS01-K-20260710-0001', 1, 'Tiền khám bệnh chuyên khoa Nội', 150000),
('NOI-BS01-K-20260710-0001', 2, 'Siêu âm màu Doppler 4D Voluson S8', 200000),
('NOI-BS01-K-20260710-0001', 3, 'Tổng phân tích tế bào máu ngoại vi', 120000),
('NOI-BS01-K-20260710-0001', 4, 'Thuốc: Nexium 40mg (14 viên)', 336000),
('NOI-BS01-K-20260710-0001', 5, 'Công khám: TS.BS Nguyễn Khắc Hưng', 150000),

-- Hóa đơn chữa nội soi BN004 (25/07/2026)
('NOI-BS01-C-20260725-0002', 1, 'Tiền điều trị & can thiệp nội soi', 150000),
('NOI-BS01-C-20260725-0002', 2, 'Tiền phòng theo dõi PK201', 100000),
('NOI-BS01-C-20260725-0002', 3, 'Công thủ thuật: TS.BS Nguyễn Khắc Hưng', 100000),

-- Hóa đơn khám nhi BN003 (20/08/2026)
('NHI-BS02-K-20260820-0003', 1, 'Tiền khám bệnh chuyên khoa Nhi', 150000),
('NHI-BS02-K-20260820-0003', 2, 'Thuốc: Klamentin 500mg (10 gói)', 120000),
('NHI-BS02-K-20260820-0003', 3, 'Thuốc: Panadol Extra đỏ (10 viên)', 20000),
('NHI-BS02-K-20260820-0003', 4, 'Công khám: ThS.BS Trần Thanh Hằng', 150000),

-- Hóa đơn chữa khí dung BN003 (22/08/2026)
('NHI-BS02-C-20260822-0004', 1, 'Tiền chữa bệnh khí dung phế quản', 100000),
('NHI-BS02-C-20260822-0004', 2, 'Sử dụng máy hút dịch Medela', 40000),
('NHI-BS02-C-20260822-0004', 3, 'Dịch vụ khí dung thuốc', 60000),
('NHI-BS02-C-20260822-0004', 4, 'Công bác sĩ: ThS.BS Trần Thanh Hằng', 100000),
('NHI-BS02-C-20260822-0004', 5, 'Công y tá: ĐD Đỗ Thị Thúy', 50000),

-- Hóa đơn đánh giá xuất viện BN003 (25/08/2026)
('NHI-BS02-C-20260825-0005', 1, 'Tiền khám đánh giá xuất viện', 80000),
('NHI-BS02-C-20260825-0005', 2, 'Công bác sĩ: ThS.BS Trần Thanh Hằng', 100000),

-- Hóa đơn khám tim mạch BN002 (01/09/2026)
('NOI-BS01-K-20260901-0006', 1, 'Tiền khám bệnh chuyên khoa Tim mạch', 150000),
('NOI-BS01-K-20260901-0006', 2, 'Điện tim vi tính 6 cần Fukuda', 80000),
('NOI-BS01-K-20260901-0006', 3, 'Xét nghiệm tế bào máu ngoại vi', 120000),
('NOI-BS01-K-20260901-0006', 4, 'Xét nghiệm Glucose máu tĩnh mạch', 45000),
('NOI-BS01-K-20260901-0006', 5, 'Thuốc: Amlodipin 5mg (30 viên)', 105000),
('NOI-BS01-K-20260901-0006', 6, 'Công khám: TS.BS Nguyễn Khắc Hưng', 150000),

-- Hóa đơn chữa tim mạch BN002 (03/09/2026)
('NOI-BS01-C-20260903-0007', 1, 'Tiền điều trị hạ áp & theo dõi Holter', 120000),
('NOI-BS01-C-20260903-0007', 2, 'Tiền phòng theo dõi nội khoa PK201', 100000),
('NOI-BS01-C-20260903-0007', 3, 'Công bác sĩ điều trị: TS.BS Nguyễn Khắc Hưng', 100000),
('NOI-BS01-C-20260903-0007', 4, 'Công điều dưỡng theo dõi: CNĐD Hoàng Thị Lan', 30000),

-- Hóa đơn khám tái phát dạ dày BN004 (05/09/2026)
('NOI-BS01-K-20260905-0008', 1, 'Tiền khám tiêu hóa ngoài giờ', 150000),
('NOI-BS01-K-20260905-0008', 2, 'Thuốc: Nexium 40mg (14 viên)', 336000),
('NOI-BS01-K-20260905-0008', 3, 'Công khám ngoài giờ: TS.BS Nguyễn Khắc Hưng', 250000),

-- Hóa đơn khám TMH BN001 (10/09/2026)
('TMH-BS03-K-20260910-0009', 1, 'Tiền khám Tai Mũi Họng', 150000),
('TMH-BS03-K-20260910-0009', 2, 'Sử dụng hệ thống nội soi ống mềm Pentax', 150000),
('TMH-BS03-K-20260910-0009', 3, 'Dịch vụ nội soi TMH chẩn đoán', 180000),
('TMH-BS03-K-20260910-0009', 4, 'Thuốc: Augmentin 1g (14 viên)', 259000),
('TMH-BS03-K-20260910-0009', 5, 'Thuốc: Panadol Extra đỏ (10 viên)', 20000),
('TMH-BS03-K-20260910-0009', 6, 'Công khám: BSCKI Đặng Quốc Tuấn', 150000),

-- Hóa đơn làm thủ thuật TMH BN001 (12/09/2026)
('TMH-BS03-C-20260912-0010', 1, 'Tiền thủ thuật hút mủ amidan & sát khuẩn', 100000),
('TMH-BS03-C-20260912-0010', 2, 'Sử dụng phòng thủ thuật PK103', 50000),
('TMH-BS03-C-20260912-0010', 3, 'Thuốc xịt mũi Otrivin 0.1% (1 lọ)', 55000),
('TMH-BS03-C-20260912-0010', 4, 'Công bác sĩ thủ thuật: BSCKI Đặng Quốc Tuấn', 100000),
('TMH-BS03-C-20260912-0010', 5, 'Công y tá phụ tá: ĐD Vũ Văn Nam', 50000),

-- Hóa đơn khám RHM BN005 (15/09/2026)
('RHM-BS04-K-20260915-0011', 1, 'Tiền khám chuyên khoa Răng Hàm Mặt', 150000),
('RHM-BS04-K-20260915-0011', 2, 'Sử dụng ghế nha khoa Anthos A3', 100000),
('RHM-BS04-K-20260915-0011', 3, 'Dịch vụ lấy cao răng và đánh bóng', 150000),
('RHM-BS04-K-20260915-0011', 4, 'Thuốc: Rodogyl (20 viên)', 150000),
('RHM-BS04-K-20260915-0011', 5, 'Thuốc: Panadol Extra đỏ (10 viên)', 20000),
('RHM-BS04-K-20260915-0011', 6, 'Công khám: ThS.BS Lê Mai Phương', 150000),

-- Hóa đơn chữa tủy RHM BN005 (18/09/2026)
('RHM-BS04-C-20260918-0012', 1, 'Tiền điều trị diệt tủy răng', 150000),
('RHM-BS04-C-20260918-0012', 2, 'Sử dụng phòng nha khoa PK104', 60000),
('RHM-BS04-C-20260918-0012', 3, 'Công bác sĩ điều trị: ThS.BS Lê Mai Phương', 100000),

-- Hóa đơn khám sức khỏe định kỳ BN007 (20/09/2026)
('NOI-BS01-K-20260920-0013', 1, 'Tiền khám sức khỏe tổng quát', 200000),
('NOI-BS01-K-20260920-0013', 2, 'Đo điện tim 6 cần Fukuda', 80000),
('NOI-BS01-K-20260920-0013', 3, 'Tổng phân tích tế bào máu ngoại vi', 120000),
('NOI-BS01-K-20260920-0013', 4, 'Định lượng Glucose máu tĩnh mạch', 45000),
('NOI-BS01-K-20260920-0013', 5, 'Công khám: TS.BS Nguyễn Khắc Hưng', 250000);

-- 12.19 Bảng thanh toán lương tháng cho cán bộ nhân viên y tế
INSERT INTO Luong (MaLuong, MaNV, Thang, NgayNhanLuong, LuongCoBan, TienThuong, TongLuong, GhiChu) VALUES
('LG-BS01-202607', 'NV_BS01', '2026-07-01', '2026-08-05', 8370000, 200000, 8570000, 'Lương tháng 07/2026 - Thưởng 1 ca khỏi bệnh (BN004)'),
('LG-YT01-202607', 'NV_YT01', '2026-07-01', '2026-08-05', 4806000, 0, 4806000, 'Lương tháng 07/2026'),
('LG-BS02-202608', 'NV_BS02', '2026-08-01', '2026-09-05', 7182000, 200000, 7382000, 'Lương tháng 08/2026 - Thưởng 1 ca khỏi bệnh (BN003)'),
('LG-YT02-202608', 'NV_YT02', '2026-08-01', '2026-09-05', 4212000, 50000, 4262000, 'Lương tháng 08/2026 - Thưởng 1 ca phụ tá khí dung'),
('LG-BS01-202609', 'NV_BS01', '2026-09-01', '2026-09-27', 8370000, 0, 8370000, 'Tạm ứng lương tháng 09/2026'),
('LG-BS03-202609', 'NV_BS03', '2026-09-01', '2026-09-27', 7776000, 0, 7776000, 'Tạm ứng lương tháng 09/2026'),
('LG-BS04-202609', 'NV_BS04', '2026-09-01', '2026-09-27', 6588000, 0, 6588000, 'Tạm ứng lương tháng 09/2026'),
('LG-BS05-202609', 'NV_BS05', '2026-09-01', '2026-09-27', 8964000, 0, 8964000, 'Tạm ứng lương tháng 09/2026'),
('LG-YT01-202609', 'NV_YT01', '2026-09-01', '2026-09-27', 4806000, 0, 4806000, 'Tạm ứng lương tháng 09/2026'),
('LG-YT03-202609', 'NV_YT03', '2026-09-01', '2026-09-27', 4410000, 50000, 4460000, 'Tạm ứng lương tháng 09/2026 - Thưởng 1 ca phụ tá TMH');

-- =====================================================================
-- KẾT THÚC TOÀN BỘ SCRIPT CÀI ĐẶT & CHÈN DỮ LIỆU MẪU
-- =====================================================================
