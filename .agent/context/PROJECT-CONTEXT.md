# Project Context: Hệ Thống Quản Lý Phòng Khám Bệnh Tư Nhân (Clinic Master)

- **Đề tài**: Đề tài 4 (STT 16 đến 20 + 37) - Học viện Công nghệ Bưu chính Viễn thông (PTIT).
- **Học phần**: Các Hệ Thống Cơ Sở Dữ Liệu.
- **Giảng viên hướng dẫn**: TS. Phan Thị Hà.
- **Kiến trúc**: Fullstack Web Application (Client - Server 3 tầng), 100% đường dẫn tương đối.

---

## 1. Hạ Tầng & Thông Số Kỹ Thuật (Infrastructure Specs)

| Thành phần | Công nghệ / Phiên bản | Thông số kết nối / Địa chỉ |
| :--- | :--- | :--- |
| **Hệ Điều Hành** | Windows 11 64-bit / Linux / macOS | Hỗ trợ đa nền tảng |
| **Node.js runtime** | Node.js v24.14.0, npm 11.9.0 | Local / Docker Alpine |
| **Java runtime** | Java 17 LTS (Temurin JRE) | Local / Docker Multi-stage |
| **Maven build tool** | Apache Maven 3.9.9 | Local compile |
| **Database Engine** | PostgreSQL 17 | Container `phongkham_postgres` / Docker |
| **Database Name** | `phong_kham2` (kết nối chính) | User: `postgres`, Password: `123456`, Port `5432` |
| **Backend REST API** | Java Spring Boot 3.3 + JPA Hibernate | `http://localhost:8080/api/v1` |
| **Swagger UI** | SpringDoc OpenAPI 3 | `http://localhost:8080/swagger-ui.html` |
| **Frontend UI** | React 18 + Vite 6 + Tailwind CSS | `http://localhost:5173` (Dev) hoặc `http://localhost:80` (Nginx) |
| **Triển khai 1 lệnh** | Docker Compose (`Clinic/deploy`) | `start.bat` (Windows), `start.sh` (Linux/macOS) |
| **Cloud Database** | **Neon.tech (PostgreSQL 17)** | Host: `ep-little-water-b4t2fgoh-pooler.c-6.us-east-2.aws.neon.tech`<br>Port: `5432`<br>Database: `neondb`<br>User: `neondb_owner`<br>Password: `npg_d5YybOm3HShF`<br>SSL Mode: `Require` |
| **Cloud Backend API** | **Render.com Web Service** | `https://clinic-backend-04f2.onrender.com`<br>API: `https://clinic-backend-04f2.onrender.com/api/v1`<br>Swagger: `https://clinic-backend-04f2.onrender.com/swagger-ui.html` |
| **Cloud Frontend UI** | **Vercel.com** | Kết nối qua `VITE_API_BASE_URL` |
| **GitHub Repository** | GitHub Student | `https://github.com/ndkien98/clinic-management` |

---

## 2. Cấu Trúc Thư Mục Toàn Dự Án (100% Đường Dẫn Tương Đối)

```
Clinic/
├── deploy/                     # Triển khai toàn bộ hệ thống bằng Docker 1 lệnh
│   ├── docker-compose.yml      # Orchestration cho PostgreSQL, Backend, Frontend
│   ├── Dockerfile.backend      # Multi-stage build Java 17 JRE
│   ├── Dockerfile.frontend     # Multi-stage build Node 20 + Nginx Alpine
│   ├── nginx.conf              # Reverse proxy Nginx cho SPA và API Backend
│   ├── start.bat & start.sh    # Script 1 chạm tự build và chạy toàn bộ hệ thống
│   └── stop.bat & stop.sh      # Script dừng toàn bộ container
├── backend/                    # Mã nguồn Backend (Spring Boot 3 + Java 17)
│   ├── src/main/java/com/example/clinic/
│   │   ├── config/             # DatabaseInitializer, Swagger, WebMvc CORS
│   │   ├── controller/         # MasterData, BenhNhan, KhamChua, DuocPham, VienPhi, ThongKe
│   │   ├── service/ & impl/    # Logic điều trị BCNF, trừ kho, hồ sơ 360, lương thưởng
│   │   ├── repository/         # 18 JPA Repositories ánh xạ DB
│   │   └── entity/             # Ánh xạ đầy đủ 24 bảng CSDL PostgreSQL
│   ├── src/main/resources/
│   │   ├── application.yml     # Cấu hình CSDL phong_kham2 (hỗ trợ biến môi trường linh hoạt)
│   │   └── db/script/          # Đóng gói 01_schema.sql và 02_sample_data.sql vào classpath
│   └── pom.xml
├── frontend/                   # Mã nguồn Frontend (React 18 + Vite 6 + Tailwind CSS)
│   ├── src/
│   │   ├── api/client.js       # Gọi REST API thực tế với URL tương đối (/api/v1)
│   │   ├── App.jsx             # Giao diện Medical Clinical Dashboard + Toast + Master + 360° + Báo Cáo
│   │   ├── main.jsx & index.css
│   │   └── index.html
│   └── package.json & vite.config.js
├── requirements/               # Đề cương BTL, Báo cáo lý thuyết & Script CSDL gốc
│   ├── BaoCao_DeTai4_PhongKham.docx.md   # Báo cáo lý thuyết và thiết kế CSDL
│   ├── DeCuongBTL (1).pdf               # Đề cương BTL Đề tài 4
│   ├── funtion.txt & doc.txt            # Bản đặc tả chi tiết các yêu cầu tính năng
│   └── Script/                          # 01_schema.sql & 02_sample_data.sql
├── infa/                       # Cấu hình docker-compose gốc của cơ sở hạ tầng
└── .agent/                     # Thư mục tri thức và tự động hóa AI Agent
    ├── skills/                 # Spring Boot Best Practices, UI Tailwind Patterns
    ├── plans/                  # Các bản kế hoạch kỹ thuật PLAN-001 -> PLAN-004
    ├── thinking/               # Lý giải kiến trúc THINKING-001 -> THINKING-004
    ├── tasks/                  # Bảng theo dõi tiến độ công việc TASK-TRACKER.md
    ├── context/                # Ngữ cảnh chi tiết dự án, CSDL, Business Rules & User Manual
    └── workflows/              # Workflow Auto-test + Test runner kiểm thử tự động
```

---

## 3. Bản Đồ 24 Bảng CSDL Trong PostgreSQL (`phong_kham2`)

1. `nhanvienyte`: Bảng cha nhân sự y tế (Quan hệ kế thừa ISA).
2. `bacsy`: Bác sĩ điều trị chuyên khoa (Kế thừa từ `nhanvienyte`).
3. `yta`: Y tá điều dưỡng hỗ trợ (Kế thừa từ `nhanvienyte`).
4. `khoa`: Các chuyên khoa y tế (Khoa Nội, Khoa Ngoại, Khoa Nhi, Chẩn đoán hình ảnh...).
5. `phongkham`: Hệ thống phòng khám, phòng chức năng và buồng bệnh.
6. `giuongbenh`: Danh sách giường bệnh và trạng thái thời gian thực (`Trong` / `CoNguoi`).
7. `benhnhan`: Hồ sơ tiếp nhận bệnh nhân, số CCCD duy nhất.
8. `danhmucbenh`: Phân loại bệnh lý theo mã ICD chuẩn y tế.
9. `sukienyte`: Thực thể cha sự kiện y tế (Kế thừa ISA).
10. `lankham`: Lần khám ban đầu của bác sĩ (Kế thừa từ `sukienyte`).
11. `lanchuabenh`: Các lần thực hiện kỹ thuật/tiểu phẫu (Kế thừa từ `sukienyte`).
12. `dotdieutri`: Chuẩn hóa BCNF - gom chuỗi khám/chữa liên tiếp, theo dõi tái phát qua `madottruoc`.
13. `thuoc`: Danh mục dược phẩm, đơn vị tính, đơn giá, kiểm soát tồn kho.
14. `sudungthuoc`: Kê đơn thuốc cho từng sự kiện y tế (Database trigger tự động trừ tồn kho).
15. `thietbi`: Máy móc trang thiết bị y tế theo từng khoa.
16. `sudungthietbi`: Ghi nhận nhật ký sử dụng thiết bị cho bệnh nhân.
17. `dichvuyte`: Danh mục xét nghiệm, siêu âm, thủ thuật y tế.
18. `sudungdichvu`: Chi tiết dịch vụ y tế bệnh nhân đã sử dụng.
19. `hoadon`: Hóa đơn viện phí tổng hợp từ các chi phí của sự kiện y tế.
20. `hoadonchitiet`: Bóc tách chi tiết từng dòng viện phí (tiền khám, thuốc, dịch vụ, giường).
21. `luong`: Bảng lương nhân sự y tế theo tháng, tính theo công thức thưởng chuẩn Đề tài 4.
22. `lichlamviec`: Lịch phân ca trực của bác sĩ và y tá.
23. `nhanvien_khoa`: Quan hệ phân bổ nhân viên vào khoa chuyên môn.
24. `chucnang_phong`: Chức năng phân loại của từng phòng khám.

---

## 4. Tài Liệu Hướng Dẫn & Tri Thức Liên Quan

- **Hướng Dẫn Sử Dụng & Kịch Bản Chi Tiết**: [USER-MANUAL-AND-FEATURES.md](file:///Clinic/.agent/context/USER-MANUAL-AND-FEATURES.md)
- **Quy Tắc Nghiệp Vụ Toàn Dự Án**: [BUSINESS-RULES.md](file:///Clinic/.agent/context/BUSINESS-RULES.md)
- **Bản Đồ CSDL & Lược Đồ BCNF**: [DATABASE-MAP.md](file:///Clinic/.agent/context/DATABASE-MAP.md)
- **Bảng Theo Dõi Tiến Độ (Task Tracker)**: [TASK-TRACKER.md](file:///Clinic/.agent/tasks/TASK-TRACKER.md)
- **README Gốc Dự Án**: [README.md](file:///Clinic/README.md)
