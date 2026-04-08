# Hướng Dẫn Đầy Đủ: Từ Tạo Tài Khoản Đến Chạy Giao Diện Trên Databricks

Tài liệu này hướng dẫn đầy đủ theo thứ tự thực tế: tạo tài khoản, tạo repo, upload code, build và chạy backend + frontend trên Databricks.

Repo sử dụng trong hướng dẫn này:

```text
https://github.com/HoangThienDe20/KTHDVVDTDM
```

## 1. Điều kiện trước khi chạy

1. Bạn đã đăng nhập Databricks Workspace.
2. Bạn đã có repo GitHub: https://github.com/HoangThienDe20/KTHDVVDTDM
3. Bạn có quyền tạo cluster trong Databricks.

## 2. Chuẩn bị source code (2 cách)

### Cách A: Khuyến nghị - dùng GitHub Repo đã có sẵn

Repo sử dụng:

```text
https://github.com/HoangThienDe20/KTHDVVDTDM
```

### Cách B: Upload trực tiếp lên Databricks Workspace Files

1. Vào Databricks Workspace.
2. Upload cả thư mục dự án.
3. Dùng đường dẫn thư mục đã upload để chạy lệnh.

Lưu ý: Cách A dễ quản lý phiên bản hơn và tiện cập nhật về sau.

## 3. Import code vào Databricks Repos (nếu dùng Cách A)

1. Vào mục Workspace trong Databricks.
2. Chọn Create -> Git folder (hoặc Connect to a GitHub repo).
3. Dán URL repo GitHub:

```text
https://github.com/HoangThienDe20/KTHDVVDTDM
```
4. Databricks Free Edition thường không hiện ô chọn branch khi tạo Git folder.
5. Repo sẽ clone theo default branch trên GitHub (hãy đảm bảo default branch là main).
6. Sau khi import xong, bạn sẽ có đường dẫn dạng:

```text
/Workspace/Users/<databricks-user>/KTHDVVDTDM
```

Mẹo kiểm tra nhanh:
1. Ở danh sách file, cạnh tên repo cần thấy nhãn branch là main.
2. Nếu không phải main, vào menu Git của repo để Switch branch sang main.

## 4. Tạo cluster để chạy

1. Vào Compute.
2. Chọn Create compute.
3. Chọn Runtime khuyến nghị: DBR 14+.
4. Chờ trạng thái cluster là Running.

## 5. Tạo notebook chạy dự án

1. Trong repo, tạo notebook mới (ví dụ: run_project).
2. Attach notebook vào cluster vừa tạo.
3. Chạy theo đúng thứ tự từng cell bên dưới.

## 6. Cài dependencies

### Cell 1 (Python)

```python
%pip install -r /Workspace/Users/<databricks-user>/KTHDVVDTDM/requirements.txt
```

Nếu Databricks yêu cầu restart Python, hãy restart rồi chạy tiếp các cell sau.

## 7. Build frontend

### Cell 2 (Shell)

```bash
%sh
cd /Workspace/Users/<databricks-user>/KTHDVVDTDM/frontend
npm install
npm run build
```

Kết quả build nằm trong thư mục `frontend/dist`.

## 8. Chạy backend FastAPI

### Cell 3 (Shell - giữ chạy liên tục)

```bash
%sh
cd /Workspace/Users/<databricks-user>/KTHDVVDTDM
export HOST=0.0.0.0
export PORT=8000
export UVICORN_RELOAD=false
python -m uvicorn app.main:app --host $HOST --port $PORT
```

Ghi chú:
1. Cell này sẽ chạy liên tục, không tự kết thúc.
2. Không dùng Run All vì cell chạy server sẽ chặn các cell khác.

## 9. Bơm dữ liệu để dashboard có số liệu

### Cell 4 (Shell - bơm nhanh dữ liệu ban đầu)

```bash
%sh
cd /Workspace/Users/<databricks-user>/KTHDVVDTDM
python -c "import requests; [requests.post('http://127.0.0.1:8000/api/system/collect', timeout=5) for _ in range(30)]; print('seeded')"
```

### Cell 5 (Shell - realtime, tùy chọn)

```bash
%sh
cd /Workspace/Users/<databricks-user>/KTHDVVDTDM
export METRICS_API_BASE_URL=http://127.0.0.1:8000
python collect_system_metrics.py --interval 2
```

## 10. Chạy frontend để lên giao diện

### Cell 6 (Shell - giữ chạy liên tục)

```bash
%sh
cd /Workspace/Users/<databricks-user>/KTHDVVDTDM/frontend
export VITE_SERVER_IP=127.0.0.1
export VITE_SERVER_PORT=8000
npm run dev -- --host 0.0.0.0 --port 3000
```

## 11. Mở giao diện từ trình duyệt

Sau khi frontend chạy ở cổng 3000, mở link theo mẫu:

```text
https://<databricks-workspace>/driver-proxy/o/<workspace-id>/<cluster-id>/3000/
```

Bạn lấy `<workspace-id>` và `<cluster-id>` ngay từ URL Databricks hiện tại.

## 12. Đăng nhập demo

- admin / 123456
- user / 123456

## 13. Kiểm tra backend nhanh

### Cell 7 (Python)

```python
import requests
print(requests.get("http://127.0.0.1:8000/api/health", timeout=10).json())
```

Nếu trả về `status: healthy` là backend chạy tốt.

## 14. Run All hay chạy từng cell?

Nên chạy từng cell theo thứ tự:
1. Cell cài package
2. Cell build frontend
3. Cell chạy backend
4. Cell bơm dữ liệu
5. Cell chạy frontend

Không nên Run All, vì các cell server (backend/frontend/collector) là tiến trình dài hạn.

## 15. Nếu không thấy dữ liệu trên dashboard

1. Kiểm tra backend còn chạy ở cell chạy uvicorn.
2. Chạy lại Cell 4 để seed dữ liệu.
3. Đảm bảo frontend dùng `VITE_SERVER_IP=127.0.0.1` và `VITE_SERVER_PORT=8000`.
4. Mở tab Network trên trình duyệt, kiểm tra các request `/api/...` có trả về 200 không.

## 16. Dừng hệ thống

1. Quay lại cell backend/frontend/collector đang chạy.
2. Bấm Stop ở từng cell đó.
3. Nếu không dùng nữa, terminate cluster để tiết kiệm chi phí.

## 17. Ghi chú production

1. SQLite trên DBFS phù hợp cho demo và học tập.
2. Production nên dùng PostgreSQL/MySQL managed service.
3. Không bật chế độ reload khi chạy production.
