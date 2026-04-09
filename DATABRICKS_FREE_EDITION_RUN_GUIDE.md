# Hướng Dẫn Chạy Dự Án Trên Databricks Free Edition (SQL Warehouse)

Tài liệu này dùng cho trường hợp tài khoản chỉ có SQL Warehouse (không có nút Create compute).

## 1. Mục tiêu và giới hạn

- Mục tiêu: Chạy được bài trên Databricks Free Edition bằng Databricks SQL.
- Giới hạn: Không chạy được FastAPI/Uvicorn/Vite dev server trong SQL Warehouse.
- Cách làm: Tạo bảng metrics demo trong Delta + chạy query + tạo dashboard trên Databricks SQL.

## 2. Chuẩn bị

1. Bạn đã import repo vào Databricks Workspace (Git folder).
2. Trong menu Compute, bạn thấy SQL Warehouses và có warehouse `Serverless Starter Warehouse`.
3. Trong repo có sẵn 2 file:

- `databricks_sql/01_setup_metrics_demo.sql`
- `databricks_sql/02_dashboard_queries.sql`

## 3. Bật SQL Warehouse

1. Vào Compute -> SQL Warehouses.
2. Chọn `Serverless Starter Warehouse`.
3. Bấm `Start` và chờ đến khi trạng thái sẵn sàng.

## 4. Tạo dữ liệu demo

1. Vào SQL Editor -> New query.
2. Mở file `databricks_sql/01_setup_metrics_demo.sql` trong repo, copy toàn bộ nội dung.
3. Paste vào SQL Editor và Run.
4. Xác nhận kết quả:

- `total_rows` xấp xỉ 5760
- Có đủ 8 metric types

Nếu muốn tạo lại dữ liệu từ đầu, chạy lại script 01 (script đã có `TRUNCATE TABLE`).

## 5. Chạy query dashboard

1. Tạo query mới trong SQL Editor.
2. Mở file `databricks_sql/02_dashboard_queries.sql`, copy nội dung.
3. Chạy từng block query (hoặc chạy tất cả nếu editor hỗ trợ).
4. Lưu từng query với tên dễ nhớ:

- Latest Metrics
- Avg CPU Memory 15m
- Server Time Series 2h
- IoT Time Series 6h
- Alert Count 1h
- Top Sources

## 6. Tạo dashboard trên Databricks SQL

1. Vào Dashboards -> Create dashboard.
2. Add visualization từ các query đã lưu ở bước 5.
3. Gợi ý loại biểu đồ:

- Latest Metrics: Table
- Avg CPU Memory 15m: KPI/Single value
- Server Time Series 2h: Line chart
- IoT Time Series 6h: Line chart
- Alert Count 1h: Bar chart
- Top Sources: Bar chart

4. Sắp xếp layout và Save.

## 7. Nội dung báo cáo/bảo vệ đề tài

Bạn có thể trình bày rõ:

1. Hệ thống vẫn sử dụng mô hình metrics (CPU, memory, IoT, alerts) như đề tài gốc.
2. Do giới hạn Databricks Free Edition (chỉ SQL Warehouse), nhóm triển khai thành Data + SQL Dashboard trên Databricks.
3. Dashboard vẫn thể hiện:

- Giá trị mới nhất
- Chuỗi thời gian
- Tổng hợp cảnh báo
- Phân bố nguồn dữ liệu

## 8. Xử lý lỗi thường gặp

1. Lỗi schema/table không tồn tại:
- Chạy lại file `01_setup_metrics_demo.sql`.

2. Warehouse dừng:
- Vào SQL Warehouse và bấm `Start`.

3. Query không có dữ liệu:
- Kiểm tra đã chạy script 01 chưa.
- Chạy `SELECT count(*) FROM metrics_demo.metrics;`.

## 9. Phạm vi thay đổi code

Để chạy được trên Databricks Free Edition, dự án đã bổ sung:

- `databricks_sql/01_setup_metrics_demo.sql`: Tạo schema, bảng Delta, seed dữ liệu metrics.
- `databricks_sql/02_dashboard_queries.sql`: Bộ query dashboard theo các chỉ số chính.

Lưu ý: Frontend React + Backend FastAPI giữ nguyên để chạy local, nhưng không được sử dụng để runtime trên SQL Warehouse.
