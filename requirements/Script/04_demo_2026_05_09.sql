-- Dữ liệu GIẢ LẬP phục vụ học tập: 05–09/2026, không phải hồ sơ y tế thật.
-- 300 bệnh nhân, 360 đợt (60 tái phát), 1080 lượt khám/chữa và hóa đơn.
-- Mọi bản ghi mới dùng tiền tố Q5; không cập nhật hồ sơ có sẵn.
-- Chạy toàn bộ file bằng psql -v ON_ERROR_STOP=1 hoặc Execute SQL Script.
-- Transaction nguyên khối; chạy lại sẽ bỏ qua nếu bộ dữ liệu đã tồn tại.
BEGIN;
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '60s';
SELECT pg_advisory_xact_lock(2026, 509);

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
  IF EXISTS (SELECT 1 FROM benhnhan WHERE mabn LIKE 'Q5BN%') THEN
    IF (SELECT count(*) FROM benhnhan WHERE mabn LIKE 'Q5BN%') <> 300
       OR (SELECT count(*) FROM sukienyte WHERE masukien LIKE 'Q5-%') <> 1080
       OR (SELECT count(*) FROM hoadon WHERE masukien LIKE 'Q5-%') <> 1080 THEN
      RAISE EXCEPTION 'Bộ Q5 đã tồn tại nhưng không đầy đủ; dừng để tránh ghi đè.';
    END IF;
    RAISE NOTICE 'Bộ Q5 đã có; bỏ qua, không trừ tồn kho lần nữa.';
    RETURN;
  END IF;

  SELECT giatri INTO base_salary FROM thamsohethong WHERE tenthamso='LUONG_CO_SO';
  SELECT giatri INTO bonus_doctor FROM thamsohethong WHERE tenthamso='THUONG_BS_HOAN_THANH';
  SELECT giatri INTO bonus_nurse FROM thamsohethong WHERE tenthamso='THUONG_YTA_HOTRO';
  IF base_salary IS NULL OR bonus_doctor IS NULL OR bonus_nurse IS NULL THEN
    RAISE EXCEPTION 'Thiếu tham số lương trong ThamSoHeThong.';
  END IF;

  FOR i IN 1..3 LOOP
    INSERT INTO khoa VALUES ('Q5K'||i, (ARRAY['Nội tổng quát','Cơ xương khớp','Tai mũi họng'])[i]||' [Mẫu Q5]', 'Dữ liệu giả lập tháng 5–9/2026');
    INSERT INTO nhanvienyte(manv,hoten,gioitinh,ngaysinh,makhoa,hesoluong,ngayvaolam,loainv)
    VALUES ('Q5BS'||i,'Bác sĩ mẫu Q5 '||i,'M','1980-01-01','Q5K'||i,3.5+i*0.2,'2026-01-01','BACSY'),
           ('Q5YT'||i,'Y tá mẫu Q5 '||i,'F','1990-01-01','Q5K'||i,2.4+i*0.1,'2026-01-01','YTA');
    INSERT INTO bacsy(mabs,email,chuyenmon) VALUES ('Q5BS'||i,'q5bs'||i||'@example.invalid','Chuyên môn giả lập');
    INSERT INTO yta VALUES ('Q5YT'||i,'DEMO-Q5-'||i);
    INSERT INTO phongkham VALUES ('Q5P'||i,'Phòng mẫu Q5 '||i,'Khám và điều trị','Q5K'||i,50000);
    INSERT INTO danhmucbenh VALUES ('Q5B'||i,(ARRAY['Viêm dạ dày','Viêm khớp','Viêm họng'])[i], 'Bệnh mẫu Q5','Chỉ dùng kiểm thử');
    INSERT INTO thuoc VALUES ('Q5T'||i,'Thuốc giả lập Q5 '||i,'viên',2000+i*1000,'Dữ liệu học tập',10000);
  END LOOP;
  INSERT INTO loainhancong VALUES ('Q5NC','Hỗ trợ điều trị mẫu Q5',30000);
  INSERT INTO dichvuyte VALUES ('Q5DV','Dịch vụ giả lập Q5',100000);
  INSERT INTO thietbi VALUES ('Q5TB','Thiết bị giả lập Q5',80000);

  FOR i IN 1..300 LOOP
    month_no := 5+(i-1)/60;
    INSERT INTO benhnhan(mabn,hoten,gioitinh,ngaysinh,diachi,ngaydangky)
    VALUES ('Q5BN'||lpad(i::text,3,'0'),
      (ARRAY['Nguyễn','Trần','Lê','Phạm','Hoàng','Vũ'])[(i-1)%6+1]||' '||
      (ARRAY['Minh An','Thu Hà','Quang Huy','Ngọc Linh','Đức Nam','Thanh Mai','Gia Bảo','Khánh Vy','Tuấn Anh','Phương Thảo'])[(i-1)%10+1]||' [Mẫu Q5]',
      CASE WHEN i%2=0 THEN 'F' ELSE 'M' END,
      make_date(1960+i%45,1+i%12,1+i%27),
      'Địa chỉ giả lập - không phải hồ sơ thật',make_date(2026,month_no,1));
  END LOOP;

  FOR i IN 1..360 LOOP
    p := CASE WHEN i<=300 THEN i ELSE i-300 END;
    dept := (p-1)%3+1;
    patient_id := 'Q5BN'||lpad(p::text,3,'0');
    doctor_id := 'Q5BS'||dept;
    nurse_id := 'Q5YT'||dept;
    room_id := 'Q5P'||dept;
    disease_id := 'Q5B'||dept;
    medicine_id := 'Q5T'||dept;
    course_id := 'Q5-DT-'||lpad(i::text,3,'0');
    month_no := CASE WHEN i<=300 THEN 5+(i-1)/60 ELSE 9 END;
    day_no := CASE WHEN i<=240 AND (i-1)%60<3 THEN 27 ELSE 1+(p-1)%18 END;
    started := make_date(2026,month_no,day_no);
    previous_id := CASE WHEN i>300 THEN 'Q5-DT-'||lpad(p::text,3,'0') ELSE NULL END;
    is_open := i BETWEEN 281 AND 300;
    finished := CASE WHEN is_open THEN NULL ELSE started+6 END;
    drug_price := 2000+dept*1000;

    -- Khám và hai lần chữa; cùng bệnh nhân, bác sĩ trong cả đợt.
    FOR j IN 0..2 LOOP
      event_id := 'Q5-'||CASE WHEN j=0 THEN 'K' ELSE 'C' END||'-'||lpad(i::text,3,'0')||'-'||j;
      visited := (started+j*3)::timestamp + interval '8 hours' + (i%8)*interval '1 hour';
      fee := CASE WHEN j=0 THEN 150000 ELSE 200000 END;
      quantity := 3+(i+j)%5;
      INSERT INTO sukienyte VALUES (event_id,patient_id,doctor_id,visited,CASE WHEN j=0 THEN 'KHAM' ELSE 'CHUA' END);
      IF j=0 THEN
        INSERT INTO lankham VALUES (event_id,'Q5K'||dept,'Triệu chứng giả lập phục vụ kiểm thử',fee);
        INSERT INTO dotdieutri(madotdieutri,masukienkham,mabenh,mucdonang,solanchuadukien,ngaybatdau,ngayketthuc,trangthai,madottruoc)
        VALUES (course_id,event_id,disease_id,CASE WHEN i%3=0 THEN 'Vua' ELSE 'Nhe' END,
          CASE WHEN is_open THEN 4 ELSE 2 END,started,finished,
          CASE WHEN is_open THEN 'DangDieuTri' ELSE 'DaKhoi' END,previous_id);
      ELSE
        INSERT INTO lanchuabenh VALUES (event_id,course_id,'Điều trị ngoại trú',
          CASE WHEN j=2 AND NOT is_open THEN 'Da khoi - dữ liệu giả lập' ELSE 'Tiếp tục theo dõi - dữ liệu giả lập' END,fee,room_id);
        INSERT INTO sudungnhancong VALUES (event_id,nurse_id,'Q5NC','Hỗ trợ điều trị',30000);
      END IF;
      INSERT INTO sudungthuoc VALUES (event_id,medicine_id,quantity,drug_price);
      IF i%2=0 AND j=0 THEN
        INSERT INTO sudungdichvu VALUES (event_id,'Q5DV',1,100000);
      END IF;
      IF i%3=0 AND j=1 THEN
        INSERT INTO sudungthietbi VALUES (event_id,'Q5TB',1,80000);
      END IF;
      INSERT INTO hoadon VALUES (event_id,visited,0,
        CASE WHEN month_no=9 AND i%4=0 THEN 'ChuaThanhToan' ELSE 'DaThanhToan' END);
      INSERT INTO hoadonchitiet VALUES
        (event_id,1,CASE WHEN j=0 THEN 'Tiền khám' ELSE 'Tiền chữa' END,fee),
        (event_id,2,'Thuốc giả lập Q5',quantity*drug_price);
      IF j>0 THEN
        INSERT INTO hoadonchitiet VALUES (event_id,3,'Nhân công hỗ trợ',30000),(event_id,4,'Sử dụng phòng',50000);
      END IF;
      IF i%2=0 AND j=0 THEN
        INSERT INTO hoadonchitiet VALUES (event_id,5,'Dịch vụ giả lập Q5',100000);
      END IF;
      IF i%3=0 AND j=1 THEN
        INSERT INTO hoadonchitiet VALUES (event_id,6,'Thiết bị giả lập Q5',80000);
      END IF;
    END LOOP;
  END LOOP;

  -- Chỉ đồng bộ các bản ghi mới của bộ Q5. Hoạt động cả khi DB có/không có trigger.
  UPDATE hoadon h SET tongtien=(SELECT sum(sotien) FROM hoadonchitiet d WHERE d.masukien=h.masukien)
  WHERE h.masukien LIKE 'Q5-%';
  UPDATE thuoc t SET tonkho=10000-(SELECT coalesce(sum(soluong),0) FROM sudungthuoc s WHERE s.mathuoc=t.mathuoc)
  WHERE t.mathuoc IN ('Q5T1','Q5T2','Q5T3');

  FOR staff IN SELECT * FROM nhanvienyte WHERE manv IN ('Q5BS1','Q5BS2','Q5BS3','Q5YT1','Q5YT2','Q5YT3') LOOP
    FOR k IN 5..9 LOOP
      IF staff.loainv='BACSY' THEN
        SELECT count(*)*bonus_doctor INTO bonus FROM dotdieutri d JOIN sukienyte s ON s.masukien=d.masukienkham
        WHERE s.mabs=staff.manv AND d.trangthai='DaKhoi' AND date_trunc('month',d.ngayketthuc)=make_date(2026,k,1);
      ELSE
        SELECT count(*)*bonus_nurse INTO bonus FROM sudungnhancong n JOIN sukienyte s USING(masukien)
        WHERE n.manv=staff.manv AND date_trunc('month',s.thoigian)=make_date(2026,k,1);
      END IF;
      INSERT INTO luong VALUES ('Q5L-'||staff.manv||'-'||k,staff.manv,make_date(2026,k,1),NULL,
        base_salary*staff.hesoluong,bonus,base_salary*staff.hesoluong+bonus,'Bảng lương giả lập Q5; chưa ghi nhận chi trả');
    END LOOP;
  END LOOP;

  IF (SELECT count(*) FROM sukienyte WHERE masukien LIKE 'Q5-%')<>1080
     OR (SELECT count(*) FROM hoadon WHERE masukien LIKE 'Q5-%')<>1080
     OR (SELECT count(*) FROM dotdieutri WHERE madotdieutri LIKE 'Q5-%')<>360
     OR EXISTS (SELECT 1 FROM hoadon h WHERE h.masukien LIKE 'Q5-%' AND h.tongtien<>(SELECT sum(sotien) FROM hoadonchitiet d WHERE d.masukien=h.masukien)) THEN
    RAISE EXCEPTION 'Kiểm tra dữ liệu Q5 thất bại; rollback toàn bộ.';
  END IF;
  RAISE NOTICE 'Đã thêm bộ dữ liệu giả lập Q5/2026.';
END;
$seed$;
COMMIT;

SELECT to_char(thoigian,'YYYY-MM') AS thang,
       count(*) FILTER (WHERE loaisukien='KHAM') AS lan_kham,
       count(*) FILTER (WHERE loaisukien='CHUA') AS lan_chua,
       count(*) AS tong_luot
FROM sukienyte WHERE masukien LIKE 'Q5-%' GROUP BY 1 ORDER BY 1;
