-- Dữ liệu GIẢ LẬP phục vụ học tập: 07–09/2026, không phải hồ sơ y tế thật.
-- 60 bệnh nhân, 70 đợt (10 tái phát), 210 lượt khám/chữa và hóa đơn.
-- Mọi bản ghi mới dùng tiền tố Q3; không cập nhật hồ sơ có sẵn.
-- Chạy toàn bộ file bằng psql -v ON_ERROR_STOP=1 hoặc Execute SQL Script.
-- Transaction nguyên khối; chạy lại sẽ bỏ qua nếu bộ dữ liệu đã tồn tại.
BEGIN;
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '60s';
SELECT pg_advisory_xact_lock(2026, 703);

DO $seed$
DECLARE
  i integer; j integer; k integer; p integer; dept integer;
  month_no integer; day_no integer; quantity integer;
  patient_id text; doctor_id text; nurse_id text; course_id text;
  event_id text; medicine_id text; disease_id text; room_id text;
  started date; visited timestamp; finished date; previous_id text;
  is_open boolean; fee numeric; drug_price numeric; bonus numeric;
  base_salary numeric; bonus_doctor numeric; bonus_nurse numeric;
  staff record;
BEGIN
  IF EXISTS (SELECT 1 FROM benhnhan WHERE mabn LIKE 'Q3BN%') THEN
    IF (SELECT count(*) FROM benhnhan WHERE mabn LIKE 'Q3BN%') <> 60
       OR (SELECT count(*) FROM sukienyte WHERE masukien LIKE 'Q3-%') <> 210
       OR (SELECT count(*) FROM hoadon WHERE masukien LIKE 'Q3-%') <> 210 THEN
      RAISE EXCEPTION 'Bộ Q3 đã tồn tại nhưng không đầy đủ; dừng để tránh ghi đè.';
    END IF;
    RAISE NOTICE 'Bộ Q3 đã có; bỏ qua, không trừ tồn kho lần nữa.';
    RETURN;
  END IF;

  SELECT giatri INTO base_salary FROM thamsohethong WHERE tenthamso='LUONG_CO_SO';
  SELECT giatri INTO bonus_doctor FROM thamsohethong WHERE tenthamso='THUONG_BS_HOAN_THANH';
  SELECT giatri INTO bonus_nurse FROM thamsohethong WHERE tenthamso='THUONG_YTA_HOTRO';
  IF base_salary IS NULL OR bonus_doctor IS NULL OR bonus_nurse IS NULL THEN
    RAISE EXCEPTION 'Thiếu tham số lương trong ThamSoHeThong.';
  END IF;

  FOR i IN 1..3 LOOP
    INSERT INTO khoa VALUES ('Q3K'||i, (ARRAY['Nội tổng quát','Cơ xương khớp','Tai mũi họng'])[i]||' [Mẫu Q3]', 'Dữ liệu giả lập quý 3/2026');
    INSERT INTO nhanvienyte(manv,hoten,gioitinh,ngaysinh,makhoa,hesoluong,ngayvaolam,loainv)
    VALUES ('Q3BS'||i,'Bác sĩ mẫu Q3 '||i,'M','1980-01-01','Q3K'||i,3.5+i*0.2,'2026-01-01','BACSY'),
           ('Q3YT'||i,'Y tá mẫu Q3 '||i,'F','1990-01-01','Q3K'||i,2.4+i*0.1,'2026-01-01','YTA');
    INSERT INTO bacsy(mabs,email,chuyenmon) VALUES ('Q3BS'||i,'q3bs'||i||'@example.invalid','Chuyên môn giả lập');
    INSERT INTO yta VALUES ('Q3YT'||i,'DEMO-Q3-'||i);
    INSERT INTO phongkham VALUES ('Q3P'||i,'Phòng mẫu Q3 '||i,'Khám và điều trị','Q3K'||i,50000);
    INSERT INTO danhmucbenh VALUES ('Q3B'||i,(ARRAY['Viêm dạ dày','Viêm khớp','Viêm họng'])[i], 'Bệnh mẫu Q3','Chỉ dùng kiểm thử');
    INSERT INTO thuoc VALUES ('Q3T'||i,'Thuốc giả lập Q3 '||i,'viên',2000+i*1000,'Dữ liệu học tập',10000);
  END LOOP;
  INSERT INTO loainhancong VALUES ('Q3NC','Hỗ trợ điều trị mẫu Q3',30000);
  INSERT INTO dichvuyte VALUES ('Q3DV','Dịch vụ giả lập Q3',100000);
  INSERT INTO thietbi VALUES ('Q3TB','Thiết bị giả lập Q3',80000);

  FOR i IN 1..60 LOOP
    month_no := 7+(i-1)/20;
    INSERT INTO benhnhan(mabn,hoten,gioitinh,ngaysinh,diachi,ngaydangky)
    VALUES ('Q3BN'||lpad(i::text,3,'0'),
      (ARRAY['Nguyễn','Trần','Lê','Phạm','Hoàng','Vũ'])[(i-1)%6+1]||' '||
      (ARRAY['Minh An','Thu Hà','Quang Huy','Ngọc Linh','Đức Nam','Thanh Mai','Gia Bảo','Khánh Vy','Tuấn Anh','Phương Thảo'])[(i-1)%10+1]||' [Mẫu Q3]',
      CASE WHEN i%2=0 THEN 'F' ELSE 'M' END,
      make_date(1960+i%45,1+i%12,1+i%27),
      'Địa chỉ giả lập - không phải hồ sơ thật',make_date(2026,month_no,1));
  END LOOP;

  FOR i IN 1..70 LOOP
    p := CASE WHEN i<=60 THEN i ELSE i-60 END;
    dept := (p-1)%3+1;
    patient_id := 'Q3BN'||lpad(p::text,3,'0');
    doctor_id := 'Q3BS'||dept;
    nurse_id := 'Q3YT'||dept;
    room_id := 'Q3P'||dept;
    disease_id := 'Q3B'||dept;
    medicine_id := 'Q3T'||dept;
    course_id := 'Q3-DT-'||lpad(i::text,3,'0');
    month_no := CASE WHEN i<=60 THEN 7+(i-1)/20 ELSE 9 END;
    day_no := CASE WHEN i<=40 AND (i-1)%20<3 THEN 27 ELSE 1+(p-1)%18 END;
    started := make_date(2026,month_no,day_no);
    previous_id := CASE WHEN i>60 THEN 'Q3-DT-'||lpad(p::text,3,'0') ELSE NULL END;
    is_open := i BETWEEN 53 AND 60;
    finished := CASE WHEN is_open THEN NULL ELSE started+6 END;
    drug_price := 2000+dept*1000;

    -- Khám và hai lần chữa; cùng bệnh nhân, bác sĩ trong cả đợt.
    FOR j IN 0..2 LOOP
      event_id := 'Q3-'||CASE WHEN j=0 THEN 'K' ELSE 'C' END||'-'||lpad(i::text,3,'0')||'-'||j;
      visited := (started+j*3)::timestamp + interval '8 hours' + (i%8)*interval '1 hour';
      fee := CASE WHEN j=0 THEN 150000 ELSE 200000 END;
      quantity := 3+(i+j)%5;
      INSERT INTO sukienyte VALUES (event_id,patient_id,doctor_id,visited,CASE WHEN j=0 THEN 'KHAM' ELSE 'CHUA' END);
      IF j=0 THEN
        INSERT INTO lankham VALUES (event_id,'Q3K'||dept,'Triệu chứng giả lập phục vụ kiểm thử',fee);
        INSERT INTO dotdieutri(madotdieutri,masukienkham,mabenh,mucdonang,solanchuadukien,ngaybatdau,ngayketthuc,trangthai,madottruoc)
        VALUES (course_id,event_id,disease_id,CASE WHEN i%3=0 THEN 'Vua' ELSE 'Nhe' END,
          CASE WHEN is_open THEN 4 ELSE 2 END,started,finished,
          CASE WHEN is_open THEN 'DangDieuTri' ELSE 'DaKhoi' END,previous_id);
      ELSE
        INSERT INTO lanchuabenh VALUES (event_id,course_id,'Điều trị ngoại trú',
          CASE WHEN j=2 AND NOT is_open THEN 'Da khoi - dữ liệu giả lập' ELSE 'Tiếp tục theo dõi - dữ liệu giả lập' END,fee,room_id);
        INSERT INTO sudungnhancong VALUES (event_id,nurse_id,'Q3NC','Hỗ trợ điều trị',30000);
      END IF;
      INSERT INTO sudungthuoc VALUES (event_id,medicine_id,quantity,drug_price);
      IF i%2=0 AND j=0 THEN
        INSERT INTO sudungdichvu VALUES (event_id,'Q3DV',1,100000);
      END IF;
      IF i%3=0 AND j=1 THEN
        INSERT INTO sudungthietbi VALUES (event_id,'Q3TB',1,80000);
      END IF;
      INSERT INTO hoadon VALUES (event_id,visited,0,
        CASE WHEN month_no=9 AND i%4=0 THEN 'ChuaThanhToan' ELSE 'DaThanhToan' END);
      INSERT INTO hoadonchitiet VALUES
        (event_id,1,CASE WHEN j=0 THEN 'Tiền khám' ELSE 'Tiền chữa' END,fee),
        (event_id,2,'Thuốc giả lập Q3',quantity*drug_price);
      IF j>0 THEN
        INSERT INTO hoadonchitiet VALUES (event_id,3,'Nhân công hỗ trợ',30000),(event_id,4,'Sử dụng phòng',50000);
      END IF;
      IF i%2=0 AND j=0 THEN
        INSERT INTO hoadonchitiet VALUES (event_id,5,'Dịch vụ giả lập Q3',100000);
      END IF;
      IF i%3=0 AND j=1 THEN
        INSERT INTO hoadonchitiet VALUES (event_id,6,'Thiết bị giả lập Q3',80000);
      END IF;
    END LOOP;
  END LOOP;

  -- Chỉ đồng bộ các bản ghi mới của bộ Q3. Hoạt động cả khi DB có/không có trigger.
  UPDATE hoadon h SET tongtien=(SELECT sum(sotien) FROM hoadonchitiet d WHERE d.masukien=h.masukien)
  WHERE h.masukien LIKE 'Q3-%';
  UPDATE thuoc t SET tonkho=10000-(SELECT coalesce(sum(soluong),0) FROM sudungthuoc s WHERE s.mathuoc=t.mathuoc)
  WHERE t.mathuoc IN ('Q3T1','Q3T2','Q3T3');

  FOR staff IN SELECT * FROM nhanvienyte WHERE manv IN ('Q3BS1','Q3BS2','Q3BS3','Q3YT1','Q3YT2','Q3YT3') LOOP
    FOR k IN 7..9 LOOP
      IF staff.loainv='BACSY' THEN
        SELECT count(*)*bonus_doctor INTO bonus FROM dotdieutri d JOIN sukienyte s ON s.masukien=d.masukienkham
        WHERE s.mabs=staff.manv AND d.trangthai='DaKhoi' AND date_trunc('month',d.ngayketthuc)=make_date(2026,k,1);
      ELSE
        SELECT count(*)*bonus_nurse INTO bonus FROM sudungnhancong n JOIN sukienyte s USING(masukien)
        WHERE n.manv=staff.manv AND date_trunc('month',s.thoigian)=make_date(2026,k,1);
      END IF;
      INSERT INTO luong VALUES ('Q3L-'||staff.manv||'-'||k,staff.manv,make_date(2026,k,1),NULL,
        base_salary*staff.hesoluong,bonus,base_salary*staff.hesoluong+bonus,'Bảng lương giả lập Q3; chưa ghi nhận chi trả');
    END LOOP;
  END LOOP;

  IF (SELECT count(*) FROM sukienyte WHERE masukien LIKE 'Q3-%')<>210
     OR (SELECT count(*) FROM hoadon WHERE masukien LIKE 'Q3-%')<>210
     OR (SELECT count(*) FROM dotdieutri WHERE madotdieutri LIKE 'Q3-%')<>70
     OR EXISTS (SELECT 1 FROM hoadon h WHERE h.masukien LIKE 'Q3-%' AND h.tongtien<>(SELECT sum(sotien) FROM hoadonchitiet d WHERE d.masukien=h.masukien)) THEN
    RAISE EXCEPTION 'Kiểm tra dữ liệu Q3 thất bại; rollback toàn bộ.';
  END IF;
  RAISE NOTICE 'Đã thêm bộ dữ liệu giả lập Q3/2026.';
END;
$seed$;
COMMIT;

SELECT to_char(thoigian,'YYYY-MM') AS thang,
       count(*) FILTER (WHERE loaisukien='KHAM') AS lan_kham,
       count(*) FILTER (WHERE loaisukien='CHUA') AS lan_chua,
       count(*) AS tong_luot
FROM sukienyte WHERE masukien LIKE 'Q3-%' GROUP BY 1 ORDER BY 1;
