#!/bin/bash

# Kiểm tra tham số đầu vào
if [ -z "$1" ]; then
    echo "Cách sử dụng: $0 <file_code_sinh_vien.c>"
    exit 1
fi

STUDENT_FILE=$1
EXECUTABLE="./student_bin_q5_v3"

echo "======================================================"
echo "                 LOADING: PROBLEM 5                   "
echo "======================================================"

# 1. Biên dịch mã nguồn C
echo "Đang biên dịch $STUDENT_FILE..."
gcc "$STUDENT_FILE" -o "$EXECUTABLE" 2> compile_errors.txt

if [ $? -ne 0 ]; then
    echo "❌ FAIL: Lỗi biên dịch (Compile Error)!"
    cat compile_errors.txt
    rm -f compile_errors.txt
    exit 1
fi
echo "✅ Biên dịch thành công."
echo "------------------------------------------------------"

# 2. Test Case 1: Luồng chuẩn (lseek, read, write nối)
echo -e "\n[Test Case 1/5] Đọc lseek và ghi nối (O_APPEND)..."
rm -f data.bin audit.log
echo -n "abcdefghijklmnopqrstuvwxyz0123456789ABCD" > data.bin
echo -n "LOG_START: " > audit.log
chmod 0644 audit.log

./$EXECUTABLE > /dev/null 2>&1

if [ -f "audit.log" ]; then
    CONTENT=$(cat audit.log)
    EXPECTED="LOG_START: pqrstuvwxyz012345678"
    if [ "$CONTENT" == "$EXPECTED" ]; then
        echo "✅ PASS: Đã lseek qua 15 byte và ghi nối đúng 20 byte tiếp theo."
    else
        echo "❌ FAIL: Nội dung file không khớp."
        echo "   + Got: $CONTENT"
        echo "   + Expect: $EXPECTED"
    fi
else
    echo "❌ FAIL: File audit.log bị mất hoặc lỗi."
fi

# 3. Test Case 2: Kiểm tra stat (Không có quyền ghi Owner)
echo -e "\n[Test Case 2/5] Kiểm tra bắt lỗi stat st_mode (Owner không có quyền ghi)..."
# Trả file về gốc và khóa quyền ghi (0444 = r--r--r--)
echo -n "LOG_START: " > audit.log
chmod 0444 audit.log

OUTPUT_TC2=$(./$EXECUTABLE 2>&1 | tr '[:upper:]' '[:lower:]')
CONTENT_TC2=$(cat audit.log)

# Khôi phục quyền để script có thể xóa file sau này
chmod 0644 audit.log

if [ "$CONTENT_TC2" == "LOG_START: " ]; then
    if [[ "$OUTPUT_TC2" != "" ]]; then
         echo "✅ PASS: Chương trình từ chối ghi và có in thông báo lỗi ra màn hình."
    else
         echo "⚠️ PASS (một phần): Chương trình từ chối ghi (đúng), nhưng KHÔNG in ra thông báo lỗi."
    fi
else
    echo "❌ FAIL: Chương trình vẫn ghi đè/nối được vào file dù không có quyền (Có thể do chạy dưới quyền root hoặc lỗi logic)."
fi

# 4. Test Case 3: Tạo mới file và cờ O_CREAT
echo -e "\n[Test Case 3/5] Tạo mới audit.log và cấp quyền rw-r--r--..."
rm -f audit.log
./$EXECUTABLE > /dev/null 2>&1

if [ -f "audit.log" ]; then
    PERM=$(stat -c "%a" audit.log)
    if [ "$PERM" == "644" ]; then
        echo "✅ PASS: Tự tạo file mới với quyền 0644 thành công."
    else
        echo "❌ FAIL: Đã tạo file nhưng sai quyền truy cập. Got: $PERM (Expect: 644)."
    fi
else
    echo "❌ FAIL: Không thể tạo mới audit.log (Thiếu cờ O_CREAT?)."
fi

# 5. Test Case 4: Xử lý lỗi perror (Thiếu data.bin)
echo -e "\n[Test Case 4/5] Xử lý lỗi bằng perror() khi thiếu file gốc..."
rm -f data.bin
OUTPUT_TC4=$(./$EXECUTABLE 2>&1 | tr '[:upper:]' '[:lower:]')

if [[ "$OUTPUT_TC4" == *"no such file"* ]] || [[ "$OUTPUT_TC4" == *"directory"* ]] || [[ "$OUTPUT_TC4" == *"lỗi"* ]]; then
    echo "✅ PASS: Đã sử dụng perror() để báo lỗi."
else
    echo "❌ FAIL: Không bắt được lỗi bằng perror() khi thiếu data.bin."
fi

# 6. Quét Static Code (Bắt buộc dùng stat)
echo -e "\n[Test Case 5/5] Kiểm tra source code..."
if grep -q "stat" "$STUDENT_FILE" && grep -q "st_mode" "$STUDENT_FILE"; then
    echo "✅ Đã tìm thấy việc sử dụng struct stat và trường st_mode."
else
    echo "❌ WARNING: Chưa dùng stat?."
fi

# Dọn dẹp môi trường
rm -f "$EXECUTABLE" data.bin audit.log compile_errors.txt
echo -e "\n======================================================"
echo "                     TESTING DONE!                      "
echo "======================================================"