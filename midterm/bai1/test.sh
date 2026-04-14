#!/bin/bash

# Kiểm tra truyền file input
if [ -z "$1" ]; then
    echo "Cách sử dụng: $0 <đường_dẫn_đến_check_access.sh>"
    exit 1
fi

STUDENT_SCRIPT=$1
REPORT_FILE="security_report.txt"

# Cấp quyền thực thi
sudo chmod +x "$STUDENT_SCRIPT"

echo "======================================================"
echo "                 LOADING: PROBLEM 1                   "
echo "======================================================"

# Xóa file report cũ nếu có
rm -f "$REPORT_FILE"

# ---------------------------------------------------------
# Test Case 1: Thư mục không tồn tại
# ---------------------------------------------------------
echo -e "\n[Test Case 1/5] Kiểm tra lỗi sai đường dẫn..."
MOCK_DIR_1="./dir_not_exists_$(date +%s)"
OUTPUT1=$($STUDENT_SCRIPT $MOCK_DIR_1 2>&1)

if [[ "$OUTPUT1" == *"Lỗi: Thư mục không tồn tại"* ]]; then
    echo "✅ PASS: Đã in thông báo lỗi chính xác."
else
    echo "❌ FAIL: Thông báo lỗi chưa khớp."
    echo "   Expect: 'Lỗi: Thư mục không tồn tại'"
    echo "   Got: '$OUTPUT1'"
fi

# ---------------------------------------------------------
# Test Case 2: Thư mục hỗn hợp (Trường hợp có tệp nguy hiểm)
# ---------------------------------------------------------
echo -e "\n[Test Case 2/5] Kiểm tra logic đếm tệp nguy hiểm (Others write)..."
MOCK_DIR_2="./test_security_data"
rm -rf $MOCK_DIR_2 && mkdir -p $MOCK_DIR_2

# Tạo 3 tệp
touch $MOCK_DIR_2/safe1.txt
touch $MOCK_DIR_2/safe2.txt
touch $MOCK_DIR_2/risky1.txt
touch $MOCK_DIR_2/risky2.txt

# Thiết lập quyền: risky1 và risky2 có quyền ghi cho Others (o+w)
chmod 644 $MOCK_DIR_2/safe1.txt
chmod 600 $MOCK_DIR_2/safe2.txt
chmod 666 $MOCK_DIR_2/risky1.txt # Quyền ghi cho others
chmod 642 $MOCK_DIR_2/risky2.txt # Quyền ghi cho others (-rw-r---w-)

# Chạy script của sinh viên
OUTPUT2=$($STUDENT_SCRIPT $MOCK_DIR_2)

if [[ "$OUTPUT2" == *"Tìm thấy 2 tệp có nguy cơ bảo mật"* ]]; then
    echo "✅ PASS: Đã tìm và đếm đúng 2 tệp nguy hiểm trên màn hình."
else
    echo "❌ FAIL: Số lượng tệp đếm được không chính xác."
    echo "   Got: $OUTPUT2"
fi

# ---------------------------------------------------------
# Test Case 3: Kiểm tra File Redirection (Ghi nối >>)
# ---------------------------------------------------------
echo -e "\n[Test Case 3/5] Kiểm tra tệp security_report.txt và ghi nối..."

if [ -f "$REPORT_FILE" ]; then
    # Chạy thêm một lần nữa để kiểm tra tính năng ghi nối (append)
    $STUDENT_SCRIPT $MOCK_DIR_2 > /dev/null
    
    LINE_COUNT=$(wc -l < "$REPORT_FILE")
    
    if [ "$LINE_COUNT" -ge 2 ]; then
        echo "✅ PASS: Đã lưu kết quả vào tệp và sử dụng cơ chế ghi nối (>>)."
        echo "   Nội dung tệp report:"
        tail -n 2 "$REPORT_FILE"
    else
        echo "❌ FAIL: Tệp report tồn tại nhưng không thấy ghi nối thêm dòng mới."
    fi
else
    echo "❌ FAIL: Không tìm thấy tệp $REPORT_FILE được tạo ra."
fi

# ---------------------------------------------------------
# Kiểm tra mã nguồn
# ---------------------------------------------------------
echo -e "\n[Test Case 4/5] Kiểm tra mã nguồn..."
if grep -q "log_result" "$STUDENT_SCRIPT" || grep -q "log_result" "$STUDENT_SCRIPT"; then
    echo "✅ Đã sử dụng hàm (function log_result)."
else
    echo "❌ CẢNH BÁO: Chưa thấy định nghĩa hàm log_result."
fi

echo -e "\n[Test Case 5/5] Kiểm tra mã nguồn..."
if grep -q "for " "$STUDENT_SCRIPT"; then
    echo "✅ Đã sử dụng vòng lặp for."
else
    echo "❌ CẢNH BÁO: Đề bài yêu cầu dùng vòng lặp for."
fi

# Dọn dẹp môi trường
rm -rf $MOCK_DIR_2
echo -e "\n======================================================"
echo "                     TESTING DONE!                      "
echo "======================================================"