# Hệ Thống Quản Lý Phòng Khám Bệnh Tư Nhân (Clinic Master)

> **BÀI TẬP LỚN MÔN CÁC HỆ THỐNG CƠ SỞ DỮ LIỆU - ĐỀ TÀI 4 (STT 16 ĐẾN 20 + 37)**  
> **Học viện Công nghệ Bưu chính Viễn thông (PTIT)**  
> **Giảng viên hướng dẫn: TS. Phan Thị Hà**  
> **Kiến trúc: Fullstack Web Application (Spring Boot 3 + PostgreSQL 17 + React 18 + Docker)**  
> **Chuẩn CSDL: Đạt chuẩn Boyce-Codd (BCNF), quan hệ kế thừa ISA, đệ quy bệnh tái phát, Triggers tự động**

---

## MỤC LỤC
1. [Tổng Quan Kiến Trúc Hệ Thống](#1-tổng-quan-kiến-trúc-hệ-thống)
2. [Cấu Trúc Thư Mục Dự Án](#2-cấu-trúc-thư-mục-dự-án)
3. [Hướng Dẫn Cài Đặt & Khởi Chạy](#3-hướng-dẫn-cài-đặt--khởi-chạy)
   - [Cách 1: Khởi chạy 1 lệnh với Docker (Khuyến nghị)](#cách-1-chạy-1-lệnh-bằng-docker-khuyến-nghị)
   - [Cách 2: Khởi chạy thủ công từng dịch vụ (Local Development)](#cách-2-chạy-từng-thành-phần-thủ-công-local-dev)
   - [Cách 3: Triển khai Cloud & Thông số kết nối Online (Production Details)](#cách-3-triển-khai-cloud--thông-số-kết-nối-trực-tuyến-production-details)
4. [MÔ TẢ CHI TIẾT TẤT CẢ TÍNH NĂNG & HƯỚNG DẪN SỬ DỤNG](#4-mô-tả-chi-tiết-tất-cả-tính-năng--hướng-dẫn-sử-dụng)
   - [4.1. Bảng Điều Khiển Tổng Quan (Dashboard)](#41-bảng-điều-khiển-tổng-quan-dashboard)
   - [4.2. Tiếp Nhận & Quản Lý Hồ Sơ Bệnh Nhân (Reception)](#42-tiếp-nhận--quản-lý-hồ-sơ-bệnh-nhân-reception)
   - [4.3. Hồ Sơ Bệnh Án 360° Toàn Diện (Patient 360° - Mục 1.b)](#43-hồ-sơ-bệnh-án-360-toàn-diện-patient-360---mục-1b)
   - [4.4. Khám Bệnh & Phân Bổ Đợt Điều Trị (Examination)](#44-khám-bệnh--phân-bổ-đợt-điều-trị-examination)
   - [4.5. Kê Đơn Thuốc & Quản Lý Dược Phẩm (Prescription)](#45-kê-đơn-thuốc--quản-lý-dược-phẩm-prescription)
   - [4.6. Theo Dõi Đợt Điều Trị & Quản Lý Giường Bệnh (Treatment & Beds)](#46-theo-dõi-đợt-điều-trị--quản-lý-giường-bệnh-treatment--beds)
   - [4.7. Quản Lý Kho Thuốc & Nhập Kho Hàng (Pharmacy Inventory)](#47-quản-lý-kho-thuốc--nhập-kho-hàng-pharmacy-inventory)
   - [4.8. Thu Ngân & Viện Phí Tự Động (Billing & Invoices)](#48-thu-ngân--viện-phí-tự-động-billing--invoices)
   - [4.9. Quản Lý Dữ Liệu Danh Mục Master Data (Master Data CRUD - Mục 1)](#49-quản-lý-dữ-liệu-danh-mục-master-data-master-data-crud---mục-1)
   - [4.10. Báo Cáo Bệnh Lý Theo Tháng (Xếp Hạng Giảm Dần & Tái Phát - Mục 2.1)](#410-báo-cáo-bệnh-lý-theo-tháng-xếp-hạng-giảm-dần--tái-phát---mục-21)
   - [4.11. Báo Cáo Phân Rã Doanh Thu 5 Nguồn Thu (Mục 2.2)](#411-báo-cáo-phân-rã-doanh-thu-5-nguồn-thu-mục-22)
   - [4.12. Bảng Tính Lương Thưởng Nhân Sự Chuẩn Đề Tài 4 (Mục 3)](#412-bảng-tính-lương-thưởng-nhân-sự-chuẩn-đề-tài-4-mục-3)
   - [4.13. Hệ Thống Thông Báo Phản Hồi Thời Gian Thực (Toast Notifications)](#413-hệ-thống-thông-báo-phản-hồi-thời-gian-thực-toast-notifications)
   - [4.14. Cơ Chế Tự Động Kiểm Tra & Nạp CSDL (Database Auto-Initializer)](#414-cơ-chế-tự-động-kiểm-tra--nạp-csdl-database-auto-initializer)
5. [Danh Mục REST API Endpoints](#5-danh-mục-rest-api-endpoints)
6. [Hệ Thống Kiểm Thử Tự Động (Auto-Test Workflow)](#6-hệ-thống-kiểm-thử-tự-động-auto-test-workflow)
7. [Cam Kết Chuẩn Hóa CSDL & Điểm Nổi Bật BCNF](#7-cam-kết-chuẩn-hóa-csdl--điểm-nổi-bật-bcnf)

---

## 1. Tổng Quan Kiến Trúc Hệ Thống

Hệ thống được xây dựng theo mô hình **Client-Server 3 tầng chuẩn công nghiệp**:

```mermaid
graph TD
    User["Người Dùng / Bác Sĩ / Thu Ngân"] -->|HTTP / Browser| FE["Frontend: React 18 + Tailwind CSS + Lucide Icons (Port 5173 / 80)"]
    FE -->|REST API JSON /api/v1| BE["Backend: Java 17 + Spring Boot 3 + Hibernate JPA (Port 8080)"]
    BE -->|JDBC Connection Pool| DB[("PostgreSQL 17: phong_kham2 (Port 5432)\n24 Bảng BCNF - ISA - Triggers - SP")]
    
    subgraph Deploy ["Docker Orchestration (deploy/docker-compose.yml)"]
        FE
        BE
        DB
    end
```

- **Tầng Giao Diện (Frontend)**: React 18, Vite 6, Tailwind CSS, Lucide React Icons. Giao diện thiết kế theo phong cách Clinical Medical Dashboard cao cấp, hiển thị trực quan, tối ưu trải nghiệm người dùng y tế.
- **Tầng Xử Lý Nghiệp Vụ (Backend)**: Java 17, Spring Boot 3.3, Spring Data JPA, Hibernate, Bean Validation, OpenApi Swagger 3. Đóng gói đầy đủ các Services xử lý nghiệp vụ y tế phức tạp.
- **Tầng Dữ Liệu (Database)**: PostgreSQL 17 chứa Database `phong_kham2` với 24 bảng dữ liệu được chuẩn hóa BCNF, bảo đảm tính toàn vẹn tham chiếu, có trigger trừ kho thuốc và SP tính tiền.
- **Tự động hóa & DevOps**: Dockerfile đa tầng (Multi-stage build), Docker Compose 1 lệnh, script khởi động tương đối (`.bat`, `.sh`).

---

## 2. Cấu Trúc Thư Mục Dự Án

Toàn bộ dự án sử dụng **100% đường dẫn tương đối** (Relative Paths), giúp bất kỳ ai clone repository về máy đều có thể khởi chạy ngay lập tức mà không cần chỉnh sửa đường dẫn cấu hình:

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
    ├── context/                # Từ điển CSDL 24 bảng, Business Rules, Project Context
    └── workflows/              # Workflow Auto-test + Test runner kiểm thử tự động
```

---

## 3. Hướng Dẫn Cài Đặt & Khởi Chạy

### Cách 1: Chạy 1 Lệnh Bằng Docker (Khuyến nghị)
*Yêu cầu*: Máy tính đã cài đặt **Docker Desktop** (và đã bật Docker).

#### Trên hệ điều hành Windows:
1. Mở thư mục `Clinic/deploy/`.
2. Nhấp đúp chuột vào file **`start.bat`** (hoặc mở PowerShell / CMD tại thư mục này và gõ `.\start.bat`).

#### Trên Linux hoặc macOS:
```bash
cd Clinic/deploy
chmod +x start.sh stop.sh
./start.sh
```

Hoặc dùng trực tiếp lệnh Docker Compose (kể cả không có cờ `--build`, hệ thống vẫn tự động build lại code mới nhất nhờ `pull_policy: build`):
```bash
cd Clinic/deploy
docker compose up -d
```

> **⚡ Cơ chế tối ưu Build Image siêu tốc (BuildKit Cache Mounts)**:
> - **Backend Java**: Áp dụng Docker BuildKit `--mount=type=cache,target=/root/.m2` giúp cache toàn bộ dependencies Maven trên host giữa các lần build. Khi sửa code Java, thời gian build chỉ mất **5-10 giây** (thay vì 10 phút tải dependencies qua internet).
> - **Frontend React**: Áp dụng `.dockerignore` (loại bỏ 174MB `node_modules` thừa) và `--mount=type=cache,target=/root/.npm`. Khi sửa code React, thời gian build chỉ mất **3-5 giây**.
> - **Tự động cập nhật code mới nhất**: Cả `start.bat`, `start.sh` và `docker-compose.yml` đều được cấu hình chỉ thị `pull_policy: build` và `--force-recreate`. Mỗi lần chạy lại, hệ thống cam kết luôn được đóng gói với mã nguồn mới nhất!
> - **Tự động xử lý xung đột Port 5432**: Script `start.bat`/`start.sh` tự động phát hiện và xử lý container PostgreSQL cũ để tránh lỗi `port is already allocated`, đồng thời bảo toàn 100% dữ liệu CSDL `phong_kham2` trong volume `infa/data`.

**Các cổng dịch vụ sau khi khởi chạy:**
- **Giao diện Web (Frontend)**: **`http://localhost:5173`** (hoặc qua Nginx cổng **`http://localhost:80`**)
- **Backend REST API**: **`http://localhost:8080/api/v1`**
- **Tài liệu Swagger UI tương tác**: **`http://localhost:8080/swagger-ui.html`**
- **PostgreSQL Database**: Host `localhost`, Port `5432`, Database: `phong_kham2`, User: `postgres`, Password: `123456`

*Để dừng toàn bộ hệ thống*: Nhấp đúp chuột vào `stop.bat` (hoặc chạy `./stop.sh` / `docker compose down`).

---

### Cách 2: Chạy Từng Thành Phần Thủ Công (Local Dev)

#### Bước 1: Khởi động CSDL PostgreSQL
Chạy container PostgreSQL có sẵn trong thư mục `infa`:
```bash
cd infa
docker compose up -d
```
*(Hoặc dùng PostgreSQL cục bộ đã tạo sẵn database `phong_kham2`)*.

#### Bước 2: Khởi động Backend Spring Boot
```bash
cd Clinic/backend
mvn spring-boot:run
```
> **Cơ chế tự động nạp**: Khi Backend khởi động, component `DatabaseInitializer` sẽ tự kiểm tra xem bảng `benhnhan` đã tồn tại chưa. Nếu database rỗng, hệ thống sẽ **tự động nạp toàn bộ schema và dữ liệu mẫu** từ `01_schema.sql` và `02_sample_data.sql`.

#### Bước 3: Khởi động Frontend React
Frontend sử dụng hệ thống biến môi trường `.env` linh hoạt cho phép tùy biến URL Backend và cổng dịch vụ:
- File `.env` / `.env.development`: Khai báo URL Backend khi chạy cục bộ:
  ```env
  VITE_API_BASE_URL=http://localhost:8080/api/v1
  VITE_APP_TITLE=Hệ Thống Quản Lý Phòng Khám Tư Nhân - Đề Tài 4
  ```
- File `.env.production`: Dùng cho Docker Nginx container (mặc định `/api/v1` thông qua Reverse Proxy).
- File `.env.example`: File mẫu để sao chép cấu hình.

Chạy frontend cục bộ:
```bash
cd Clinic/frontend
npm install
npm run dev
```
Mở trình duyệt truy cập: **`http://localhost:5173`**.
> **💡 Trực quan hóa kết nối trên Header**: Ngay trên thanh Header của giao diện, hệ thống hiển thị badge trạng thái kết nối Backend (`BE: Online (http://localhost:8080/api/v1)`) kèm nút đồng bộ/tải lại dữ liệu trực tiếp, giúp người dùng dễ dàng theo dõi URL và trạng thái kết nối thời gian thực.

---

### Cách 3: Triển Khai Cloud & Thông Số Kết Nối Trực Tuyến (Production Details)

Toàn bộ hệ thống phòng khám đã được cấu hình và triển khai thực tế trên hạ tầng đám mây (Cloud Serverless & Container). Dưới đây là toàn bộ thông số kết nối chính thức:

#### 1. Cơ Sở Dữ Liệu Cloud: Neon.tech (PostgreSQL 17)
- **Host**: `ep-little-water-b4t2fgoh-pooler.c-6.us-east-2.aws.neon.tech`  
  *(Lưu ý: Luôn giữ nguyên tiền tố `ep-little-` ở đầu host name)*
- **Port**: `5432`
- **Database**: `neondb`
- **Username**: `neondb_owner`
- **Password**: `npg_d5YybOm3HShF`
- **SSL / TLS Mode**: Bắt buộc chọn **`Require`**
- **Chuỗi kết nối JDBC (Java Spring Boot)**:
  ```
  jdbc:postgresql://ep-little-water-b4t2fgoh-pooler.c-6.us-east-2.aws.neon.tech/neondb?sslmode=require
  ```
- **Chuỗi kết nối Connection String (URI)**:
  ```
  postgresql://neondb_owner:npg_d5YybOm3HShF@ep-little-water-b4t2fgoh-pooler.c-6.us-east-2.aws.neon.tech/neondb?sslmode=require
  ```

> **📌 Hướng dẫn kết nối qua các phần mềm quản trị CSDL (DBeaver, Navicat, pgAdmin, DataGrip)**:
> 1. Mở phần mềm (DBeaver / Navicat) -> Chọn tạo kết nối mới: **PostgreSQL**.
> 2. **Tab Main (Chính)**:
>    - **Host**: `ep-little-water-b4t2fgoh-pooler.c-6.us-east-2.aws.neon.tech`
>    - **Port**: `5432`
>    - **Database**: `neondb`
>    - **Username**: `neondb_owner`
>    - **Password**: `npg_d5YybOm3HShF`
> 3. **Tab SSH/SSL**:
>    - Chuyển sang tab **SSH/SSL** ở thanh phía trên.
>    - Tích chọn **Use SSL** (Sử dụng SSL).
>    - Mục **SSL Mode**: Chọn **`Require`** (hoặc `verify-ca` / `verify-full`).
> 4. Nhấn **Test Connection** -> Hệ thống báo *"Connected successfully"* -> Nhấn **OK/Finish**.
> 5. CSDL đã chứa toàn bộ 24 bảng dữ liệu chuẩn BCNF và dữ liệu mẫu đầy đủ.

#### 2. Backend Cloud: Render.com Web Service
- **Tên dịch vụ**: `clinic-backend`
- **Trạng thái**: **Live 🎉 (Đang hoạt động trực tuyến)**
- **Địa chỉ chính (Primary Live URL)**: [https://clinic-backend-04f2.onrender.com](https://clinic-backend-04f2.onrender.com)
- **API Base URL**: `https://clinic-backend-04f2.onrender.com/api/v1`
- **Tài liệu Swagger UI tương tác**: [https://clinic-backend-04f2.onrender.com/swagger-ui.html](https://clinic-backend-04f2.onrender.com/swagger-ui.html)
- **OpenAPI 3.0 Schema**: [https://clinic-backend-04f2.onrender.com/v3/api-docs](https://clinic-backend-04f2.onrender.com/v3/api-docs)

#### 3. Frontend Cloud: Vercel.com
- **Mã nguồn GitHub**: [https://github.com/ndkien98/clinic-management](https://github.com/ndkien98/clinic-management)
- **Root Directory**: `frontend`
- **Framework Preset**: `Vite`
- **Biến môi trường (Environment Variable)**:
  - `VITE_API_BASE_URL` = `https://clinic-backend-04f2.onrender.com/api/v1`

---

## 4. MÔ TẢ CHI TIẾT TẤT CẢ TÍNH NĂNG & HƯỚNG DẪN SỬ DỤNG

Dưới đây là cẩm nang hướng dẫn sử dụng chi tiết cho từng phân hệ trong ứng dụng. Toàn bộ các thao tác trên giao diện đều **kết nối với REST API thật và thay đổi dữ liệu trực tiếp trong CSDL PostgreSQL**.

```mermaid
journey
    title Hành trình nghiệp vụ khám chữa bệnh trong Clinic Master
    section Tiếp nhận
      Tiếp nhận bệnh nhân mới: 5: Tiếp tân
      Tra cứu lịch sử y bạ: 4: Tiếp tân
      Xem hồ sơ bệnh án 360°: 5: Tiếp tân, Bác sĩ
    section Khám bệnh
      Ghi nhận triệu chứng khám: 5: Bác sĩ
      Chẩn đoán & Mở đợt điều trị: 5: Bác sĩ
      Chỉ định giường bệnh trống: 5: Bác sĩ
    section Điều trị & Dược
      Kê đơn thuốc trừ tồn kho: 5: Bác sĩ, Dược sĩ
      Thực hiện lần chữa bệnh: 4: Bác sĩ, Y tá
      Kết luận khỏi bệnh giải phóng giường: 5: Bác sĩ
    section Tài chính & Quản trị
      Xác nhận thu viện phí: 5: Thu ngân
      Quản lý danh mục Master Data: 5: Quản trị viên
      Xuất báo cáo doanh thu & lương: 5: Ban giám đốc
```

---

### 4.1. Bảng Điều Khiển Tổng Quan (Dashboard)

#### Mô tả tính năng:
Màn hình trung tâm cung cấp cái nhìn 360 độ về tình hình hoạt động của phòng khám theo thời gian thực:
1. **Thẻ KPI Tổng Bệnh Nhân**: Tổng số lượng bệnh nhân đang được quản lý trong bảng `benhnhan`.
2. **Thẻ KPI Đợt Điều Trị Mở**: Số lượng các đợt điều trị đang ở trạng thái `DangDieuTri`.
3. **Thẻ KPI Giường Bệnh Đang Dùng**: Số giường bệnh hiện đang có bệnh nhân lưu trú (`CoNguoi`) kèm số giường hiện còn trống.
4. **Thẻ KPI Doanh Thu Đã Thu Phí**: Tổng số tiền viện phí thực tế đã được thu vào quỹ phòng khám (`trangThaiTT = 'DaThanhToan'`).
5. **Widget Đợt Điều Trị Gần Nhất**: Danh sách các đợt điều trị đang diễn ra, hiển thị mã đợt, bệnh lý, ngày bắt đầu, giường nằm và nút bấm **"Khỏi bệnh"** nhanh.
6. **Widget Tồn Kho Dược Phẩm**: Danh sách các loại thuốc, hiển thị đơn giá, tồn kho thực tế, cảnh báo thuốc sắp hết và nút **"+ Nhập kho"** nhanh.

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Bảng Điều Khiển"** trên menu bên trái.
2. Để đóng nhanh một đợt điều trị cho bệnh nhân đã khỏi bệnh: Tại danh sách đợt điều trị, bấm nút **"Khỏi bệnh"**. Hệ thống sẽ ngay lập tức cập nhật trạng thái đợt điều trị thành `DaKhoi` và giải phóng giường bệnh về `Trong`.
3. Để nhập thêm thuốc trực tiếp: Bấm nút **"+ Nhập kho"** tại dòng thuốc tương ứng, nhập số lượng cần bổ sung và nhấn **"Cập Nhật Kho"**.
4. Nút **"Đồng bộ lại CSDL"** ở góc dưới bên trái cho phép cưỡng bức đồng bộ lại toàn bộ dữ liệu mới nhất từ PostgreSQL.

---

### 4.2. Tiếp Nhận & Quản Lý Hồ Sơ Bệnh Nhân (Reception)

#### Mô tả tính năng:
Quản lý toàn bộ thông tin bệnh nhân đến phòng khám:
- Tìm kiếm tức thời (Real-time Filter) theo Họ tên, Số điện thoại hoặc Số CCCD.
- Form tiếp nhận bệnh nhân mới với các ràng buộc nghiệp vụ: Mã BN tự động tăng (`BNxxx`), kiểm tra tính duy nhất của Số CCCD (`SoCCCD`), kiểm tra định dạng giới tính và ngày sinh.
- Thao tác xóa hồ sơ bệnh nhân khỏi hệ thống.
- Tích hợp nút xem **"Hồ Sơ 360°"** trên từng dòng bệnh nhân.

#### Hướng dẫn sử dụng:
1. **Tìm kiếm bệnh nhân**: Nhập tên, số điện thoại hoặc CCCD vào ô tìm kiếm ở thanh header trên cùng. Bảng danh sách sẽ tự động lọc dữ liệu tương ứng.
2. **Thêm bệnh nhân mới**:
   - Nhấp vào nút **"Tiếp Nhận Mới"** (hoặc **"Thêm Bệnh Nhân"**).
   - Điền đầy đủ thông tin: Họ và tên (ví dụ: *Hoàng Văn Nam*), Giới tính (*Nam/Nữ*), Ngày sinh, Số CCCD (*12 chữ số*), Số điện thoại, Địa chỉ thường trú.
   - Nhấn **"Lưu Vào CSDL"**. Hệ thống gửi yêu cầu `POST /api/v1/benh-nhan`, lưu dữ liệu vào PostgreSQL và hiển thị thông báo Toast thành công.
3. **Xóa bệnh nhân**: Nhấn biểu tượng thùng rác màu đỏ trên dòng bệnh nhân cần xóa và xác nhận hộp thoại cảnh báo.

---

### 4.3. Hồ Sơ Bệnh Án 360° Toàn Diện (Patient 360° - Mục 1.b)

#### Mô tả tính năng:
Đáp ứng trọn vẹn yêu cầu **Mục 1.b** trong đề cương BTL và file `funtion.txt`. Đây là tính năng đột phá cho phép y bác sĩ có cái nhìn toàn diện về lịch sử và hiện trạng của bệnh nhân:
- **Phần 1: Tình trạng bệnh hiện tại (Đang điều trị)**:
  - Cho biết bệnh nhân đang mắc bệnh gì (`tenBenh`, `maBenh`).
  - Đang là lần khám/chữa thứ mấy cho mỗi bệnh trong đợt điều trị này (tự động đếm chuỗi liên tiếp: 1 lần khám + số lần chữa).
  - Bác sĩ chuyên khoa phụ trách chính (`bacSyPhuTrach`).
  - Vị trí giường bệnh đang bố trí (`maGiuong` hoặc điều trị ngoại trú).
  - Mức độ nặng của bệnh (*Nhẹ, Vừa, Nặng*).
- **Phần 2: Toàn bộ lịch sử khám/chữa bệnh từ trước đến nay**:
  - Dòng thời gian chi tiết từng sự kiện y tế (`SuKienYTe`), phân biệt rõ *Lần Khám* (`LanKham`) và *Lần Chữa Bệnh* (`LanChuaBenh`).
  - Bảng kê chi phí chi tiết từng khoản mục viện phí (`HoaDonChiTiet`): Tiền khám, tiền công chữa bệnh, tiền dịch vụ kỹ thuật, đơn giá và số lượng.
  - Chi tiết các loại thuốc đã sử dụng trong từng lần khám chữa (`SuDungThuoc`).
  - Tổng số tiền viện phí của từng sự kiện và trạng thái thanh toán (`DaThanhToan` / `ChuaThanhToan`).

#### Hướng dẫn sử dụng:
1. Tại Tab **"Tiếp Nhận & Bệnh Nhân"**, tìm bệnh nhân cần tra cứu.
2. Nhấp vào nút **"Hồ Sơ 360°"** (màu xanh ngọc có biểu tượng con mắt).
3. Cửa sổ Modal hiển thị đầy đủ:
   - Thẻ thông tin hành chính trên cùng (Mã BN, Họ tên, Giới tính, Ngày sinh, CCCD, SĐT).
   - Vùng 1: Các thẻ bệnh hiện tại đang điều trị.
   - Vùng 2: Dòng thời gian lịch sử khám chữa bệnh kèm bảng kê viện phí chi tiết từng dòng.
4. Nhấn nút **"Đóng Hồ Sơ"** (hoặc dấu ✕) để quay lại màn hình chính.

---

### 4.4. Khám Bệnh & Phân Bổ Đợt Điều Trị (Examination)

#### Mô tả tính năng:
Hỗ trợ quy trình nghiệp vụ khám bệnh ban đầu của Bác sĩ:
- Tiếp nhận ghi nhận khám bệnh: Chọn Bệnh nhân, Bác sĩ khám, Khoa khám bệnh, Đơn giá tiền khám, Triệu chứng lâm sàng và chẩn đoán ban đầu.
- Cơ chế sinh mã sự kiện tự động theo quy tắc chuẩn: `<MaKhoa>-<MaBS>-K-<YYYYMMDD>-<STT>`.
- Tự động tạo bản ghi Hóa đơn viện phí (`HoaDon`) và dòng chi phí khám ban đầu (`HoaDonChiTiet`).
- **Tùy chọn mở đợt điều trị mới (Chuẩn BCNF)**:
  - Nếu bệnh nhân cần theo dõi hoặc điều trị kéo dài, bác sĩ tích chọn **"Mở Đợt Điều Trị Mới Cho Ca Bệnh Này"**.
  - Chọn Chẩn đoán bệnh (`MaBenh`), Mức độ nặng (*Nhẹ, Vừa, Nặng*).
  - Bố trí giường bệnh: Hệ thống tự động lọc danh sách các giường bệnh đang ở trạng thái trống (`Trong`). Khi gán giường, hệ thống tự động cập nhật trạng thái giường thành `CoNguoi`.

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Khám Bệnh & Kê Đơn"** trên menu bên trái.
2. Tại form bên trái **"Tiếp Nhận & Ghi Nhận Khám Bệnh"**:
   - Chọn Bệnh nhân từ danh sách thả xuống.
   - Chọn Bác sĩ khám và Khoa chuyên môn tương ứng.
   - Nhập tiền khám (mặc định 150.000 VNĐ).
   - Nhập triệu chứng bệnh nhân mô tả vào ô văn bản.
3. Nếu muốn mở đợt điều trị:
   - Tích chọn checkbox **"Mở Đợt Điều Trị Mới Cho Ca Bệnh Này (DotDieuTri)"**.
   - Chọn Mã bệnh lý chẩn đoán.
   - Chọn Mức độ nặng.
   - Chọn Giường bệnh cần bố trí (hoặc để trống nếu điều trị ngoại trú).
4. Nhấn nút **"Lưu Hồ Sơ Khám & Xuất Hóa Đơn Trực Tiếp"**. Toast notification thông báo thành công và dữ liệu lập tức được ghi vào CSDL PostgreSQL.

---

### 4.5. Kê Đơn Thuốc & Quản Lý Dược Phẩm (Prescription)

#### Mô tả tính năng:
Bác sĩ kê đơn thuốc cho bệnh nhân sau khi có kết quả khám hoặc chữa bệnh:
- Chọn sự kiện y tế cần kê đơn.
- Chọn thuốc trong danh mục: Hệ thống hiển thị rõ tên thuốc, số lượng tồn kho hiện tại và đơn giá.
- Nhập số lượng thuốc cần kê.
- **Ràng buộc Database Trigger tự động**: Hệ thống kiểm tra số lượng kê đơn có vượt quá tồn kho hay không. Nếu hợp lệ, tự động trừ số lượng tồn kho trong bảng `Thuoc`, tự động ghi đơn giá áp dụng vào bảng `SuDungThuoc` và cộng dồn số tiền thuốc vào hóa đơn viện phí của sự kiện.

#### Hướng dẫn sử dụng:
1. Tại tab **"Khám Bệnh & Kê Đơn"**, nhìn sang form bên phải **"Kê Đơn Thuốc (SuDungThuoc)"**.
2. Chọn Mã sự kiện y tế vừa tạo (ví dụ: *NOI-BS001-K-...*).
3. Chọn loại thuốc cần cấp trong danh mục (ví dụ: *Paracetamol 500mg - Còn 500 viên*).
4. Nhập số lượng kê đơn (ví dụ: *20*).
5. Nhấn **"+ Xác Nhận Kê Đơn & Trừ Tồn Kho"**.
6. Hệ thống thực thi API `POST /api/v1/thuoc/ke-don`, kho thuốc tự động giảm đi 20 viên và hóa đơn sự kiện được tự động cộng thêm số tiền thuốc tương ứng.

---

### 4.6. Theo Dõi Đợt Điều Trị & Quản Lý Giường Bệnh (Treatment & Beds)

#### Mô tả tính năng:
Theo dõi phác đồ điều trị dài ngày của bệnh nhân theo đúng mô hình chuẩn hóa BCNF:
- Hiển thị danh sách tất cả các đợt điều trị: Mã đợt, Mã sự kiện khám bắt đầu, Bệnh lý, Mức độ nặng, Giường bệnh, Ngày bắt đầu, Ngày kết thúc và Trạng thái.
- Nút bấm **"Kết luận khỏi bệnh"**: Khi bệnh nhân hoàn thành phác đồ, bác sĩ nhấn nút này để cập nhật trạng thái đợt điều trị thành `DaKhoi`, đồng thời hệ thống tự động giải phóng giường bệnh về trạng thái `Trong`.
- Hỗ trợ liên kết đệ quy `MaDotTruoc`: Khi bệnh nhân bị tái phát bệnh cũ, đợt điều trị mới sẽ trỏ về mã đợt điều trị trước đó để theo dõi tiền sử bệnh lý.

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Đợt Điều Trị & Giường"** trên menu bên trái.
2. Xem bảng danh sách các đợt điều trị. Các đợt đang điều trị có huy hiệu màu xanh dương, đợt đã khỏi có huy hiệu màu xanh lá.
3. Để đóng đợt điều trị cho bệnh nhân: Nhấn nút **"Kết luận khỏi bệnh"** tại cột Thao tác. Giường bệnh đang gán sẽ ngay lập tức được giải phóng để đón bệnh nhân mới.

---

### 4.7. Quản Lý Kho Thuốc & Nhập Kho Hàng (Pharmacy Inventory)

#### Mô tả tính năng:
Kiểm soát toàn diện kho dược phẩm phòng khám:
- Hiển thị danh mục thuốc: Mã thuốc, Tên thuốc, Hãng sản xuất, Đơn vị tính (Viên, Lọ, Gói...), Đơn giá, Tồn kho thực tế.
- **Cảnh báo tồn kho tự động**: Thuốc có tồn kho `< 200` sẽ được gắn cờ đỏ cảnh báo **"Cần nhập thêm"**. Thuốc có tồn kho `>= 200` có nhãn xanh **"Đầy đủ"**.
- Chức năng **Nhập thêm kho thuốc**: Cho phép thủ kho bổ sung số lượng thuốc vào kho bất kỳ lúc nào.

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Kho Dược Phẩm"** trên menu bên trái.
2. Kiểm tra cột Tình Trạng để nắm bắt các loại thuốc đang chạm ngưỡng cảnh báo.
3. Để nhập thêm thuốc: Nhấn nút **"+ Nhập kho"** trên dòng thuốc muốn bổ sung.
4. Hộp thoại hiện ra: Nhập số lượng cần bổ sung (ví dụ: *100*) và nhấn **"Cập Nhật Kho"**. Tồn kho của thuốc sẽ lập tức tăng thêm trong CSDL.

---

### 4.8. Thu Ngân & Viện Phí Tự Động (Billing & Invoices)

#### Mô tả tính năng:
Quản lý dòng tiền và viện phí của bệnh nhân minh bạch:
- Danh sách hóa đơn của tất cả các sự kiện y tế: Mã sự kiện, Ngày lập hóa đơn, Tổng tiền viện phí, Trạng thái thu phí (`ChuaThanhToan` / `DaThanhToan`).
- Tổng tiền viện phí được hệ thống tự động tính toán tổng hợp từ:
  $$\text{Tổng Viện Phí} = \text{Tiền Khám/Chữa} + \text{Tiền Thuốc Kê Đơn} + \text{Tiền Dịch Vụ} + \text{Tiền Giường/CSVC}$$
- Nút bấm **"Xác Nhận Thu Phí"**: Thu ngân click để xác nhận bệnh nhân đã thanh toán, hệ thống ghi nhận vào quỹ thực thu của phòng khám.

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Thu Ngân & Viện Phí"** trên menu bên trái.
2. Các hóa đơn chưa thanh toán sẽ có huy hiệu màu vàng kèm nút **"Xác Nhận Thu Phí"**.
3. Khi bệnh nhân thanh toán tiền tại quầy thu ngân: Nhấn nút **"Xác Nhận Thu Phí"**. Trạng thái hóa đơn chuyển ngay sang màu xanh lá **"Đã Thanh Toán"** và số tiền này được cộng ngay vào KPI doanh thu tổng của phòng khám.

---

### 4.9. Quản Lý Dữ Liệu Danh Mục Master Data (Master Data CRUD - Mục 1)

#### Mô tả tính năng:
Đáp ứng trọn vẹn yêu cầu **Mục 1** trong `funtion.txt`. Cho phép quản trị viên quản lý đầy đủ dữ liệu danh mục nền tảng của phòng khám cho 8 đối tượng cốt lõi:
1. **Bác Sĩ (`BacSy`)**: Kế thừa `NhanVienYTe`, quản lý Mã BS, Chuyên môn (*Nội, Ngoại, Nhi, Mắt...*), Khoa công tác.
2. **Y Tá (`YTa`)**: Kế thừa `NhanVienYTe`, quản lý Mã Y tá, Trình độ (*Cử nhân điều dưỡng, Cao đẳng...*).
3. **Danh Mục Bệnh (`DanhMucBenh`)**: Quản lý Mã bệnh (B001, B002...), Tên bệnh lý (*Viêm xoang cấp, Viêm dạ dày, Tăng huyết áp...*), Khoa phụ trách điều trị, Mô tả triệu chứng.
4. **Thiết Bị Y Tế (`ThietBi`)**: Quản lý Mã thiết bị (TB001, TB002...), Tên thiết bị (*Máy siêu âm màu 4D, Máy chụp X-quang kỹ thuật số...*), Tình trạng hoạt động, Khoa quản lý.
5. **Dịch Vụ Y Tế (`DichVuYTe`)**: Quản lý Mã dịch vụ (DV001, DV002...), Tên kỹ thuật (*Xét nghiệm sinh hóa máu, Siêu âm ổ bụng tổng quát...*), Đơn giá viện phí quy định.
6. **Phòng Khám (`PhongKham`)**: Quản lý Mã phòng (P101, P102...), Tên phòng khám (*Phòng Khám Nội 1, Phòng Tiểu Phẫu Ngoại...*), Khoa chuyên môn trực thuộc.
7. **Giường Bệnh (`GiuongBenh`)**: Quản lý Mã giường (G101, G102...), Phòng bố trí, Trạng thái thời gian thực (*Trống / Đang sử dụng*).

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Quản Lý Danh Mục"** trên menu bên trái.
2. Chọn sub-tab tương ứng phía trên: *Bác Sĩ, Y Tá, Danh Mục Bệnh, Thiết Bị Y Tế, Dịch Vụ Y Tế, Phòng Khám, Giường Bệnh*.
3. **Thêm mới**: Nhấn nút **"Thêm Mới Dữ Liệu"** ở góc trên bên phải. Điền thông tin theo form mẫu tương ứng của từng đối tượng và nhấn **"Lưu Vào CSDL"**.
4. **Xóa dữ liệu**: Nhấn biểu tượng thùng rác màu đỏ trên dòng cần xóa và xác nhận để gọi API `DELETE` tương ứng.

---

### 4.10. Báo Cáo Bệnh Lý Theo Tháng (Xếp Hạng Giảm Dần & Tái Phát - Mục 2.1)

#### Mô tả tính năng:
Đáp ứng trọn vẹn yêu cầu **Mục 2.1** trong đề cương BTL và `funtion.txt`:
- Báo cáo thống kê tần suất mắc các loại bệnh lý trong một tháng cụ thể.
- **Sắp xếp giảm dần**: Các bệnh lý có số ca mắc nhiều nhất sẽ được xếp hạng trên cùng (#1, #2, #3...).
- **Quy tắc đợt điều trị chuẩn BCNF**:
  - Chuỗi các lần khám và chữa bệnh liên tiếp của cùng một đợt điều trị (`DotDieuTri`) chỉ được tính là **1 ca mắc bệnh**.
  - Nếu bệnh nhân đã khỏi bệnh nhưng sau đó bị tái phát bệnh cũ (mở đợt điều trị mới có liên kết `MaDotTruoc`), hệ thống sẽ tính là **1 ca mắc mới (tái phát)**.
- Bảng hiển thị chi tiết: Thứ hạng, Mã bệnh, Tên bệnh lý, Khoa phụ trách, Tổng số ca mắc, Số bệnh nhân mắc phải, Phân tách số đợt mới và số đợt tái phát.

#### Hướng dẫn sử dụng:
1. Nhấp vào mục **"Báo Cáo Thống Kê"** trên menu bên trái.
2. Tại thanh lọc trên cùng, chọn Tháng/Năm cần xem (ví dụ: `2024-03`) và nhấn nút **"Xem Báo Cáo"**.
3. Cuộn xuống vùng **"Mục 2.1: Thống Kê Các Loại Bệnh Mắc Phải"** để xem bảng xếp hạng giảm dần.

---

### 4.11. Báo Cáo Phân Rã Doanh Thu 5 Nguồn Thu (Mục 2.2)

#### Mô tả tính năng:
Đáp ứng trọn vẹn yêu cầu **Mục 2.2** trong `funtion.txt`. Phân tích cấu trúc doanh thu phòng khám theo tháng thành 5 nguồn thu độc lập và minh bạch:
1. **Tiền khám bệnh**: Doanh thu từ tiền công khám ban đầu của các lần khám (`LanKham.TienKham`).
2. **Tiền chữa bệnh**: Doanh thu từ các lần chữa bệnh, vật lý trị liệu, thủ thuật (`LanChuaBenh.TienCongChua`).
3. **Tiền thuốc kê đơn**: Doanh thu bán thuốc theo đơn (`SuDungThuoc.SoLuong * Thuoc.DonGia`).
4. **Tiền dịch vụ y tế**: Doanh thu từ các xét nghiệm, siêu âm, chẩn đoán hình ảnh (`HoaDonChiTiet`).
5. **Tiền giường & CSVC**: Doanh thu từ việc lưu trú giường bệnh và sử dụng trang thiết bị y tế.

#### Hướng dẫn sử dụng:
1. Tại tab **"Báo Cáo Thống Kê"**, chọn Tháng/Năm cần thống kê.
2. Vùng **"Mục 2.2: Doanh Thu Phòng Khám Phân Rã Theo 5 Nguồn Thu"** hiển thị tổng doanh thu toàn phòng khám cùng 5 thẻ chỉ số độc lập thể hiện số tiền thu được từ từng nguồn.

---

### 4.12. Bảng Tính Lương Thưởng Nhân Sự Chuẩn Đề Tài 4 (Mục 3)

#### Mô tả tính năng:
Đáp ứng trọn vẹn yêu cầu **Mục 3** trong `funtion.txt` và đề cương BTL. Hệ thống tự động tính toán bảng lương thực lĩnh công bằng theo thành tích nghiệp vụ hàng tháng:
- **Công thức tính lương Bác sĩ**:
  $$\text{Lương Bác Sĩ} = (\text{Lương Cơ Bản} \times \text{Hệ Số Lương}) + (\text{Số ca chữa khỏi bệnh trong tháng} \times 1.000.000\,\text{VNĐ})$$
  *(Điều kiện: Đợt điều trị có `TrangThai = 'DaKhoi'` và ngày kết thúc nằm trong tháng tính lương)*.
- **Công thức tính lương Y tá**:
  $$\text{Lương Y Tá} = (\text{Lương Cơ Bản} \times \text{Hệ Số Lương}) + (\text{Số lượt hỗ trợ bệnh nhân trong tháng} \times 200.000\,\text{VNĐ})$$
- Hiển thị bảng chi tiết: Mã NV, Họ tên, Vị trí (Bác sĩ/Y tá), Chuyên môn/Trình độ, Lương cơ bản, Hệ số, Thành tích trong tháng (số ca khỏi / số lượt hỗ trợ), Tiền thưởng nghiệp vụ và Tổng thực lĩnh.

#### Hướng dẫn sử dụng:
1. Tại tab **"Báo Cáo Thống Kê"**, chọn Tháng/Năm tính lương.
2. Cuộn xuống vùng **"Mục 3: Bảng Tính Lương Nhân Viên Y Tế"** để theo dõi bảng lương chi tiết của toàn bộ đội ngũ nhân sự phòng khám.

---

### 4.13. Hệ Thống Thông Báo Phản Hồi Thời Gian Thực (Toast Notifications)

Mọi thao tác của người dùng trên giao diện đều được phản hồi tức thì qua hệ thống thông báo nổi (Toast) ở góc trên bên phải màn hình:
- **Toast Thành Công (Màu xanh ngọc)**: Thông báo khi lưu bệnh nhân, lưu khám bệnh, kê đơn thuốc, kết luận khỏi bệnh, thanh toán hóa đơn, nhập thêm kho thuốc hoặc thêm mới danh mục thành công.
- **Toast Thất Bại / Lỗi (Màu đỏ)**: Thông báo chi tiết lý do lỗi nếu Backend từ chối (ví dụ: trùng số CCCD, vượt quá tồn kho thuốc, dữ liệu thiếu trường bắt buộc).
- **Toast Cảnh Báo (Màu vàng)**: Nhắc nhở người dùng khi chưa điền đủ các thông tin cần thiết.
- Mọi thông báo tự động mờ dần và biến mất sau 4 giây, hoặc có thể đóng chủ động bằng nút ✕.

---

### 4.14. Cơ Chế Tự Động Kiểm Tra & Nạp CSDL (Database Auto-Initializer)

Hệ thống tích hợp lớp cấu hình thông minh [`DatabaseInitializer.java`](file:///Clinic/backend/src/main/java/com/example/clinic/config/DatabaseInitializer.java):
- Khi Backend Spring Boot khởi động, ứng dụng tự động kiểm tra sự tồn tại của bảng `benhnhan` trong database `phong_kham2`.
- Nếu CSDL chưa có bảng hoặc chưa có dữ liệu mẫu, hệ thống sẽ **tự động nạp file `01_schema.sql` (tạo 24 bảng, views, triggers) và `02_sample_data.sql` (nạp dữ liệu mẫu chuẩn PTIT)** được đóng gói sẵn trong classpath.
- Giúp giảng viên và người đánh giá chỉ cần khởi chạy dự án là có sẵn toàn bộ dữ liệu mẫu phong phú để kiểm thử ngay lập tức mà không cần gõ lệnh SQL thủ công!

---

## 5. Danh Mục REST API Endpoints

Hệ thống cung cấp đầy đủ tài liệu API tương tác trực tiếp qua **Swagger UI** tại: `http://localhost:8080/swagger-ui.html`.

### Bảng tóm tắt các REST API chính:
| Phân hệ | Phương thức | Endpoint URI | Mô tả chức năng |
| :--- | :---: | :--- | :--- |
| **Bệnh Nhân** | `GET` | `/api/v1/benh-nhan` | Lấy danh sách tất cả bệnh nhân |
| | `GET` | `/api/v1/benh-nhan/search` | Tìm kiếm bệnh nhân theo từ khóa (tên, SĐT, CCCD) |
| | `GET` | `/api/v1/benh-nhan/{maBN}/ho-so-360` | **Xem hồ sơ bệnh án 360° toàn diện (Mục 1.b)** |
| | `POST` | `/api/v1/benh-nhan` | Tiếp nhận bệnh nhân mới |
| | `DELETE` | `/api/v1/benh-nhan/{maBN}` | Xóa hồ sơ bệnh nhân |
| **Master Data** | `GET/POST` | `/api/v1/master/bac-sy` | Xem / Thêm mới Bác sĩ (Mục 1) |
| | `DELETE` | `/api/v1/master/bac-sy/{id}` | Xóa Bác sĩ |
| | `GET/POST` | `/api/v1/master/y-ta` | Xem / Thêm mới Y tá (Mục 1) |
| | `DELETE` | `/api/v1/master/y-ta/{id}` | Xóa Y tá |
| | `GET/POST` | `/api/v1/master/danh-muc-benh` | Xem / Thêm mới Danh mục bệnh (Mục 1) |
| | `DELETE` | `/api/v1/master/danh-muc-benh/{id}` | Xóa bệnh lý |
| | `GET/POST` | `/api/v1/master/thiet-bi` | Xem / Thêm mới Thiết bị y tế (Mục 1) |
| | `DELETE` | `/api/v1/master/thiet-bi/{id}` | Xóa thiết bị y tế |
| | `GET/POST` | `/api/v1/master/dich-vu` | Xem / Thêm mới Dịch vụ y tế (Mục 1) |
| | `DELETE` | `/api/v1/master/dich-vu/{id}` | Xóa dịch vụ y tế |
| | `GET/POST` | `/api/v1/master/phong-kham` | Xem / Thêm mới Phòng khám (Mục 1) |
| | `DELETE` | `/api/v1/master/phong-kham/{id}` | Xóa phòng khám |
| | `GET/POST` | `/api/v1/master/giuong-benh` | Xem / Thêm mới Giường bệnh (Mục 1) |
| | `DELETE` | `/api/v1/master/giuong-benh/{id}` | Xóa giường bệnh |
| **Khám & Điều Trị** | `POST` | `/api/v1/lan-kham` | Ghi nhận khám bệnh & tạo sự kiện y tế |
| | `GET` | `/api/v1/dot-dieu-tri` | Lấy danh sách đợt điều trị (lọc theo trạng thái) |
| | `POST` | `/api/v1/dot-dieu-tri` | Mở đợt điều trị mới & gán giường bệnh |
| | `PUT` | `/api/v1/dot-dieu-tri/{maDot}/dong` | Đóng đợt điều trị (kết luận khỏi bệnh & giải phóng giường) |
| **Kho Thuốc** | `GET` | `/api/v1/thuoc` | Danh mục thuốc & số lượng tồn kho |
| | `PUT` | `/api/v1/thuoc/{maThuoc}/nhap-kho` | Nhập thêm số lượng thuốc vào kho |
| | `POST` | `/api/v1/thuoc/ke-don` | Kê đơn thuốc cho bệnh nhân (tự động trừ kho) |
| **Viện Phí** | `GET` | `/api/v1/hoa-don` | Danh sách hóa đơn viện phí |
| | `PUT` | `/api/v1/hoa-don/{maSuKien}/thanh-toan` | Xác nhận thanh toán viện phí |
| **Báo Cáo** | `GET` | `/api/v1/thong-ke/tong-quan` | Chỉ số KPI tổng quan cho Dashboard |
| | `GET` | `/api/v1/thong-ke/benh-theo-thang` | **Báo cáo bệnh lý theo tháng (giảm dần, tính tái phát - Mục 2.1)** |
| | `GET` | `/api/v1/thong-ke/doanh-thu-chi-tiet` | **Doanh thu phân rã 5 nguồn thu (Mục 2.2)** |
| | `GET` | `/api/v1/thong-ke/bang-luong-chi-tiet` | **Bảng lương thưởng chuẩn Đề tài 4 (BS + YT - Mục 3)** |

---

## 6. Hệ Thống Kiểm Thử Tự Động (Auto-Test Workflow)

Dự án trang bị sẵn một bộ khung tự động kiểm thử (Test Automation Runner) viết bằng Node.js tại `.agent/workflows/test-runner.js`:

```bash
# Thực hiện chạy bộ testcases tự động
node Clinic/.agent/workflows/test-runner.js
```

### Các kịch bản kiểm thử tự động bao gồm:
1. **`TC-01-PATIENT`**: Kiểm thử tiếp nhận bệnh nhân mới, xác thực CCCD duy nhất, truy vấn hồ sơ 360°.
2. **`TC-02-EXAM-TREATMENT`**: Kiểm thử luồng khám bệnh ban đầu, mở đợt điều trị, phân bổ giường bệnh, kết luận khỏi bệnh và giải phóng giường.
3. **`TC-03-PHARMACY`**: Kiểm thử kê đơn thuốc, kích hoạt trigger kiểm tra tồn kho và trừ trực tiếp vào CSDL.
4. **`TC-04-BILLING-REPORTS`**: Kiểm thử tổng hợp hóa đơn viện phí, thanh toán, xuất báo cáo xếp hạng bệnh theo tháng, phân rã doanh thu 5 nguồn và tính lương nhân viên.

Sau khi chạy, kết quả chi tiết từng ca kiểm thử được tự động xuất ra file Markdown tại thư mục `.agent/workflows/reports/`.

---

## 7. Cam Kết Chuẩn Hóa CSDL & Điểm Nổi Bật BCNF

Hệ thống CSDL `phong_kham2` gồm **24 bảng quan hệ** được thiết kế đáp ứng chặt chẽ các tiêu chuẩn học thuật cao nhất của môn học Các Hệ Thống Cơ Sở Dữ Liệu:

1. **Chuẩn hóa Boyce-Codd (BCNF)**: Mọi phụ thuộc hàm $X \to Y$ đều có $X$ là một siêu khóa (superkey). Tách biệt hoàn toàn bảng `DotDieuTri` khỏi `LanKham` và `LanChuaBenh`, loại bỏ hoàn toàn dư thừa dữ liệu và dị thường cập nhật (Update/Insert/Delete Anomalies).
2. **Mô hình Kế thừa Chuyên biệt hóa (ISA Hierarchies)**:
   - `NhanVienYTe` là thực thể cha bao quát; `BacSy` và `YTa` là các thực thể con kế thừa khóa chính `MaNV`.
   - `SuKienYTe` là thực thể cha tổng quát; `LanKham` và `LanChuaBenh` là các thực thể con kế thừa khóa chính `MaSuKien`.
3. **Mối quan hệ đệ quy (Recursive Relationship)**: Cột `MaDotTruoc` trong bảng `DotDieuTri` tham chiếu đến chính khóa chính `MaDotDieuTri` của bảng này, cho phép mô hình hóa chuỗi bệnh án tái phát qua nhiều năm của bệnh nhân.
4. **Toàn vẹn dữ liệu bằng Triggers & Stored Procedures**:
   - Trigger tự động chặn kê đơn thuốc nếu số lượng yêu cầu vượt quá tồn kho hiện có trong bảng `Thuoc`.
   - Trigger tự động đổi trạng thái giường bệnh thành `CoNguoi` khi gán cho đợt điều trị, và chuyển về `Trong` khi đợt điều trị kết thúc.
   - Hàm Stored Procedure tính toán bảng lương thưởng theo đúng quy định thưởng 1.000.000đ cho bác sĩ và 200.000đ cho y tá.

---
*Dự án hoàn thành phục vụ bảo vệ Bài tập lớn môn Các Hệ Thống Cơ Sở Dữ Liệu - Học viện Công nghệ Bưu chính Viễn thông.*
