#!/bin/bash

# Kiểm tra truyền file input
if [ -z "$1" ]; then
    echo "Cách sử dụng: $0 <file_code_cua_sinh_vien.c>"
    echo "Ví dụ: $0 ./bai3_nguyenvan_c.c"
    exit 1
fi

STUDENT_FILE=$1
EXECUTABLE="./student_program_q3"

if [ ! -f "$STUDENT_FILE" ]; then
    echo "Error: Không tìm thấy file $STUDENT_FILE"
    exit 1
fi

echo "======================================================"
echo "                 LOADING: PROBLEM 3                   "
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

# 2. Hàm chạy test case và kiểm tra từ khóa
run_test() {
    local tc_name=$1
    local input_data=$2
    local condition_type=$3  # "found" hoặc "not_found"
    local expected_offset=$4

    echo -e "\n[Test Case $tc_name"
    
    # Chạy file thực thi
    OUTPUT=$(echo -e "$input_data" | $EXECUTABLE 2>&1)
    
    # so sánh
    LOWER_OUTPUT=$(echo "$OUTPUT" | tr '[:upper:]' '[:lower:]')
    
    if [ "$condition_type" == "found" ]; then
        # Cần tìm thấy chuỗi địa chỉ hex (0x) và số offset
        if [[ "$LOWER_OUTPUT" == *"0x"* ]] && [[ "$LOWER_OUTPUT" == *"$expected_offset"* ]]; then
             echo "✅ PASS: Tìm thấy phần tử, in ra địa chỉ và offset ($expected_offset) chính xác."
             echo "   + Input: $(echo "$input_data" | tr '\n' ' ')"
             echo "   + Got: $OUTPUT"
        else
             echo "❌ FAIL: Kết quả không khớp yêu cầu tìm thấy."
             echo "   + Input: $(echo "$input_data" | tr '\n' ' ')"
             echo "   + Got: $OUTPUT"
             echo "   + Expect: '0x' (địa chỉ) và offset '$expected_offset'."
        fi
    elif [ "$condition_type" == "not_found" ]; then
        # Cần tìm thấy thông báo không tồn tại (hỗ trợ cả tiếng Việt/Anh)
        if [[ "$LOWER_OUTPUT" == *"không"* ]] || [[ "$LOWER_OUTPUT" == *"not"* ]] || [[ "$LOWER_OUTPUT" == *"tồn tại"* ]]; then
             echo "✅ PASS: Đã báo không tìm thấy phần tử."
        else
             echo "❌ FAIL: Chưa xử lý đúng luồng không tìm thấy."
             echo "   + Input: $(echo "$input_data" | tr '\n' ' ')"
             echo "   + Got: $OUTPUT"
             echo "   + Expect: 'không tồn tại' hoặc 'not found'."
        fi
    fi
}

# 3. Thực thi 3 Test Cases

# Test Case 1: Tìm thấy phần tử ở giữa (Số 12 cách lề 3 vị trí)
run_test "1/5] Tìm thấy phần tử (Bình thường)" "5\n2 5 8 12 16\n12\n" "found" "3"

# Test Case 2: Không tồn tại trong mảng
run_test "2/5] Phần tử không tồn tại" "6\n1 3 5 7 9 11\n4\n" "not_found" ""

# Test Case 3: Trường hợp biên (Mảng 1 phần tử, offset là 0)
run_test "3/5] Mảng 1 phần tử (Edge case)" "1\n42\n42\n" "found" "0"

# Test case 4:
run_test "4/5] Phần tử ở sát mép cuối mảng" "5\n10 20 30 40 50\n50\n" "found" "4"

# Test case 5:
run_test "5/5] Phần tử ở sát mép đầu mảng" "4\n5 15 25 35\n5\n" "found" "0"

# 4. Dọn dẹp môi trường
rm -f "$EXECUTABLE" compile_errors.txt
echo -e "\n======================================================"
echo "                     TESTING DONE!                      "
echo "======================================================"
