#!/bin/bash

# Kiểm tra truyền file input
if [ -z "$1" ]; then
    echo "Cách sử dụng: $0 <file_code_cua_sinh_vien.c>"
    echo "Ví dụ: $0 ./bai2_nguyenvan_a.c"
    exit 1
fi

STUDENT_FILE=$1
EXECUTABLE="./student_program"

# Kiểm tra file C có tồn tại không
if [ ! -f "$STUDENT_FILE" ]; then
    echo "Lỗi: Không tìm thấy file $STUDENT_FILE"
    exit 1
fi

echo "======================================================"
echo "                 LOADING: PROBLEM 2                   "
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

# 2. Hàm chạy và đánh giá Test Case
run_test() {
    local tc_name=$1
    local input_data=$2
    local expected_arr=$3
    local expected_max=$4

    echo -e "\n[Test Case $tc_name"
    
    # Chạy file thực thi và truyền dữ liệu đầu vào mô phỏng bàn phím
    OUTPUT=$(echo -e "$input_data" | $EXECUTABLE 2>&1)
    
    # Chuẩn hóa chuỗi (Xóa khoảng trắng, dấu phẩy, đưa về chữ thường) để linh hoạt khi match
    NORM_OUTPUT=$(echo "$OUTPUT" | tr -d ' ,\r\n' | tr '[:upper:]' '[:lower:]')
    NORM_ARR=$(echo "$expected_arr" | tr -d ' ,')
    
    # Kiểm tra xem output có chứa chuỗi mảng sau cập nhật và giá trị Max không
    if [[ "$NORM_OUTPUT" == *"$NORM_ARR"* ]] && [[ "$NORM_OUTPUT" == *"$expected_max"* ]]; then
         echo "✅ PASS: Mảng cập nhật và giá trị Max chính xác."
         echo "   + Input: $input_data"
         echo "   + Got: Mảng [$expected_arr] và Max = $expected_max"
    else
         echo "❌ FAIL: Kết quả không khớp yêu cầu."
         echo "   + Input: $input_data"
         echo "   + Got: "
         echo "$OUTPUT"
         echo "   + Expect: Mảng [$expected_arr] và Max = $expected_max"
    fi
}

# 3. Thực thi 3 Test Cases
# Lưu ý: Truyền đầu vào cách nhau bằng khoảng trắng. Standard scanf("%d", &x) trong C sẽ tự động xử lý khoảng trắng/xuống dòng.

# Test Case 1: Tất cả đều đã có quyền Ghi (Bit 1 = 1) -> Không đổi
run_test "1/5] Tất cả đã có quyền Ghi" "3\n2 3 7\n" "2,3,7" "7"

# Test Case 2: Không ai có quyền Ghi (Bit 1 = 0) -> Cấp thêm +2 cho tất cả
run_test "2/5] Không ai có quyền Ghi" "4\n0 1 4 5\n" "2,3,6,7" "7"

# Test Case 3: Hỗn hợp và Max khác 7
run_test "3/5] Hỗn hợp & Max không phải 7" "3\n0 1 0\n" "2,3,2" "3"

# Test Case 4
run_test "4/5] Mảng toàn 0 (Không ai có quyền)" "3\n0 0 0\n" "2,2,2" "2"

# Test Case 5
run_test "5/5] Một phần tử thiếu Ghi (Đọc + Thực thi)" "1\n5\n" "7" "7"

# 4. Dọn dẹp môi trường
rm -f "$EXECUTABLE" compile_errors.txt
echo -e "\n======================================================"
echo "                     TESTING DONE!                      "
echo "======================================================"
