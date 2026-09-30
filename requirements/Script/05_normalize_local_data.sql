-- Chuẩn hóa cách hiển thị dữ liệu demo; KHÔNG biến hồ sơ demo thành hồ sơ thật.
-- Nguồn thuốc và giới hạn xác minh: xem 05_normalize_local_data.md.
-- Chạy sau 02/03/04 bằng psql -X -v ON_ERROR_STOP=1 -f <file>.
-- Không thay mã, số lượng, đơn giá, tồn kho, thời gian hoặc số tiền.
BEGIN;
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '60s';
SELECT pg_advisory_xact_lock(2026, 930);

-- Chặn ghi đồng thời; so sánh toàn bộ dữ liệu ngoài các cột được phép sửa.
CREATE TEMP TABLE cleanup_before(tab text PRIMARY KEY, rows_json jsonb) ON COMMIT DROP;
CREATE TEMP TABLE cleanup_allowed(tab text PRIMARY KEY, cols text[]) ON COMMIT DROP;
INSERT INTO cleanup_allowed VALUES
 ('benhnhan',ARRAY['hoten','diachi']), ('nhanvienyte',ARRAY['hoten']),
 ('bacsy',ARRAY['email','chuyenmon']), ('yta',ARRAY['chungchihanhnghe']),
 ('khoa',ARRAY['tenkhoa','mota']), ('phongkham',ARRAY['tenphong']),
 ('danhmucbenh',ARRAY['nhombenh','mota']), ('thuoc',ARRAY['tenthuoc','hangsx']),
 ('loainhancong',ARRAY['tenloaicong']), ('dichvuyte',ARRAY['tendv']),
 ('thietbi',ARRAY['tenthietbi']), ('lankham',ARRAY['trieuchung']),
 ('lanchuabenh',ARRAY['ketluan']), ('hoadonchitiet',ARRAY['motakhoanmuc']),
 ('luong',ARRAY['ghichu']);
DO $$
DECLARE t record; snapshot jsonb;
BEGIN
 FOR t IN SELECT c.table_name, coalesce(a.cols,ARRAY[]::text[]) cols
 FROM information_schema.tables c LEFT JOIN cleanup_allowed a ON a.tab=c.table_name
 WHERE c.table_schema='public' AND c.table_type='BASE TABLE' ORDER BY c.table_name LOOP
  EXECUTE format('LOCK TABLE public.%I IN SHARE ROW EXCLUSIVE MODE',t.table_name);
  EXECUTE format('SELECT coalesce(jsonb_agg(j ORDER BY j::text),''[]''::jsonb) FROM (SELECT to_jsonb(r)-$1 AS j FROM public.%I r) s',t.table_name) INTO snapshot USING t.cols;
  INSERT INTO cleanup_before VALUES(t.table_name,snapshot);
 END LOOP;
END $$;

DO $$
DECLARE prefix text; i integer;
BEGIN
 FOREACH prefix IN ARRAY ARRAY['Q3','Q5'] LOOP
  FOR i IN 1..3 LOOP
   UPDATE khoa SET tenkhoa=(ARRAY['Nội tổng quát','Cơ xương khớp','Tai mũi họng'])[i],
    mota=(ARRAY['Khám và điều trị nội khoa','Khám và điều trị bệnh cơ xương khớp','Khám và điều trị bệnh tai mũi họng'])[i]
   WHERE makhoa=prefix||'K'||i;
   UPDATE nhanvienyte SET hoten=CASE WHEN prefix='Q3'
    THEN (ARRAY['Nguyễn Đức Minh','Trần Quang Huy','Lê Hoàng Phúc'])[i]
    ELSE (ARRAY['Phạm Quốc Bảo','Hoàng Minh Tuấn','Vũ Anh Dũng'])[i] END
   WHERE manv=prefix||'BS'||i;
   UPDATE nhanvienyte SET hoten=CASE WHEN prefix='Q3'
    THEN (ARRAY['Nguyễn Thu Hương','Trần Ngọc Lan','Lê Thanh Hà'])[i]
    ELSE (ARRAY['Phạm Thùy Linh','Hoàng Khánh Vy','Vũ Phương Thảo'])[i] END
   WHERE manv=prefix||'YT'||i;
   UPDATE bacsy SET chuyenmon=(ARRAY['Nội tổng quát','Cơ xương khớp','Tai mũi họng'])[i],
    email=CASE WHEN email LIKE '%@example.invalid' THEN NULL ELSE email END
   WHERE mabs=prefix||'BS'||i;
   UPDATE yta SET chungchihanhnghe=NULL
   WHERE mayt=prefix||'YT'||i AND chungchihanhnghe LIKE 'DEMO-%';
   UPDATE phongkham SET tenphong=(ARRAY['Phòng khám Nội tổng quát','Phòng khám Cơ xương khớp','Phòng khám Tai mũi họng'])[i]
    ||CASE WHEN prefix='Q3' THEN ' 1' ELSE ' 2' END WHERE maphong=prefix||'P'||i;
   UPDATE danhmucbenh SET nhombenh=(ARRAY['Tiêu hóa','Cơ xương khớp','Tai mũi họng'])[i],
    mota=NULL WHERE mabenh=prefix||'B'||i;
   UPDATE thuoc SET tenthuoc=(ARRAY['Omeprazol DHG 20 mg','Mebilax 7,5 mg','Hapacol 500 mg'])[i],
    hangsx='DHG Pharma' WHERE mathuoc=prefix||'T'||i;
  END LOOP;
  UPDATE loainhancong SET tenloaicong='Hỗ trợ điều dưỡng' WHERE maloaicong=prefix||'NC';
  UPDATE dichvuyte SET tendv='Tổng phân tích tế bào máu ngoại vi' WHERE madv=prefix||'DV';
  UPDATE thietbi SET tenthietbi='Máy theo dõi chỉ số sinh tồn' WHERE mathietbi=prefix||'TB';
 END LOOP;
END $$;

-- 360 tên đầy đủ, phân bố theo giới tính; không tự tạo CCCD, điện thoại, địa chỉ.
WITH numbered AS (
 SELECT mabn, gioitinh, substring(mabn from 5)::integer - 1
  + CASE WHEN mabn LIKE 'Q5%' THEN 60 ELSE 0 END AS n
 FROM benhnhan WHERE mabn ~ '^Q[35]BN[0-9]{3}$'
)
UPDATE benhnhan b SET hoten=
 (ARRAY['Nguyễn','Trần','Lê','Phạm','Hoàng','Vũ','Đặng','Bùi','Đỗ','Hồ',
        'Ngô','Dương','Lý','Đinh','Trịnh','Mai','Phan','Võ','Đoàn','Tạ'])[n/20+1]||' '||
 CASE WHEN x.gioitinh='F' THEN
 (ARRAY['Thu Hà','Ngọc Linh','Thanh Mai','Khánh Vy','Phương Thảo','Thùy Dung','Ngọc Anh','Bảo Châu','Minh Hằng','Thanh Huyền'])[n%20/2+1]
 ELSE
 (ARRAY['Minh An','Quang Huy','Đức Nam','Gia Bảo','Tuấn Anh','Hoàng Long','Minh Khang','Quốc Khánh','Đức Huy','Anh Tuấn'])[n%20/2+1] END,
 diachi=CASE WHEN b.diachi='Địa chỉ giả lập - không phải hồ sơ thật' THEN NULL ELSE b.diachi END
FROM numbered x WHERE b.mabn=x.mabn;

UPDATE benhnhan b SET hoten=x.new_name FROM (VALUES
 ('BN01','Nguyen Van Nam','Nguyễn Văn Nam'),('BN02','Tran Thi Hoa','Trần Thị Hoa'),
 ('BN03','Le Van Binh','Lê Văn Bình'),('BN04','Pham Thi Lan','Phạm Thị Lan'),
 ('BN05','Hoang Van Duc','Hoàng Văn Đức'),('BN06','Vu Thi Mai','Vũ Thị Mai'),
 ('BN07','Do Van Phuc','Đỗ Văn Phúc'),('BN08','Bui Thi Thu','Bùi Thị Thu')
) x(id,old_name,new_name) WHERE b.mabn=x.id AND b.hoten=x.old_name;
UPDATE nhanvienyte n SET hoten=x.new_name FROM (VALUES
 ('BS01','BS. Nguyen Van A','Nguyễn Văn Thành'),('BS02','BS. Tran Thi B','Trần Thị Bích'),
 ('BS03','BS. Le Van C','Lê Văn Cường'),('YT01','YT. Pham Thi D','Phạm Thị Diễm'),
 ('YT02','YT. Hoang Van E','Hoàng Văn Hải'),('YT03','YT. Vu Thi F','Vũ Thị Hạnh')
) x(id,old_name,new_name) WHERE n.manv=x.id AND n.hoten=x.old_name;
-- Email chứa chữ cái thay tên chưa được xác minh; để trống thay vì gán người thật.
UPDATE bacsy SET email=NULL WHERE (mabs,email) IN
 (('BS01','bs.a@phongkham.vn'),('BS02','bs.b@phongkham.vn'),('BS03','bs.c@phongkham.vn'));

-- Không bịa thêm triệu chứng để thay chỗ trống của bộ sinh dữ liệu.
UPDATE lankham SET trieuchung=NULL WHERE masukien ~ '^Q[35]-'
 AND trieuchung='Triệu chứng giả lập phục vụ kiểm thử';
UPDATE lanchuabenh SET ketluan=CASE
 WHEN ketluan='Da khoi - dữ liệu giả lập' THEN 'Đã khỏi'
 WHEN ketluan='Tiếp tục theo dõi - dữ liệu giả lập' THEN 'Tiếp tục theo dõi'
 ELSE ketluan END WHERE masukien ~ '^Q[35]-';
UPDATE luong SET ghichu='Chưa ghi nhận chi trả'
 WHERE maluong ~ '^Q[35]L-' AND ghichu LIKE 'Bảng lương giả lập%';
UPDATE hoadonchitiet h SET motakhoanmuc=t.tenthuoc
 FROM sudungthuoc s JOIN thuoc t USING (mathuoc)
 WHERE h.masukien=s.masukien AND h.masukien ~ '^Q[35]-' AND h.sodong=2;
UPDATE hoadonchitiet h SET motakhoanmuc=d.tendv
 FROM sudungdichvu s JOIN dichvuyte d USING(madv)
 WHERE h.masukien=s.masukien AND h.masukien ~ '^Q[35]-' AND h.sodong=5;
UPDATE hoadonchitiet h SET motakhoanmuc=t.tenthietbi
 FROM sudungthietbi s JOIN thietbi t USING(mathietbi)
 WHERE h.masukien=s.masukien AND h.masukien ~ '^Q[35]-' AND h.sodong=6;

DO $$
DECLARE t record; snapshot jsonb;
BEGIN
 FOR t IN SELECT b.*,coalesce(a.cols,ARRAY[]::text[]) cols FROM cleanup_before b
 LEFT JOIN cleanup_allowed a USING(tab) LOOP
  EXECUTE format('SELECT coalesce(jsonb_agg(j ORDER BY j::text),''[]''::jsonb) FROM (SELECT to_jsonb(r)-$1 AS j FROM public.%I r) s',t.tab) INTO snapshot USING t.cols;
  IF snapshot IS DISTINCT FROM t.rows_json THEN
   RAISE EXCEPTION 'Dữ liệu ngoài phạm vi cho phép đã thay đổi ở bảng %; rollback.',t.tab;
  END IF;
 END LOOP;
 IF EXISTS (SELECT 1 FROM hoadon h WHERE h.masukien ~ '^Q[35]-'
  AND h.tongtien IS DISTINCT FROM (SELECT sum(sotien) FROM hoadonchitiet c WHERE c.masukien=h.masukien)) THEN
  RAISE EXCEPTION 'Tổng hóa đơn không khớp; rollback.';
 END IF;
END $$;
COMMIT;
