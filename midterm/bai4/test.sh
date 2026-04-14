#!/bin/bash

# Kiểm tra truyền file input
if [ -z "$1" ]; then
    echo "Cách sử dụng: $0 <file_code_cua_sinh_vien.c>"
    exit 1
fi

STUDENT_FILE=$1
EXECUTABLE="./student_bin_q4"

echo "======================================================"
echo "                 LOADING: PROBLEM 4                   "
echo "======================================================"

# 1. Biên dịch mã nguồn C
echo "Đang biên dịch $STUDENT_FILE..."
# Yêu cầu sinh viên dùng struct, union, enum 
gcc "$STUDENT_FILE" -o "$EXECUTABLE" 2> compile_errors.txt

if [ $? -ne 0 ]; then
    echo "❌ FAIL: Lỗi biên dịch!"
    cat compile_errors.txt
    rm -f compile_errors.txt
    exit 1
fi
echo "✅ Biên dịch thành công."
echo "------------------------------------------------------"

# 2. Hàm hỗ trợ chạy test
# Tham số: tên_test, dữ_liệu_input, chuỗi_kết_quả_mong_đợi_theo_thứ_tự
run_test() {
    local tc_name=$1
    local input_data=$2
    local expected_order=$3 # Danh sách tên sinh viên theo thứ tự GPA giảm dần

    echo -e "\n[Test Case $tc_name"
    
    # Chạy chương trình và lấy output sau dòng "After ... sort"
    OUTPUT=$(echo -e "$input_data" | $EXECUTABLE 2>&1)
    
    # Lọc lấy phần danh sách sau khi sắp xếp để kiểm tra [cite: 91, 211]
    AFTER_SORT=$(echo "$OUTPUT" | sed -n '/After/,$p')
    
    # Kiểm tra thứ tự xuất hiện của các tên sinh viên trong output
    MATCH=true
    PREV_POS=0
    for NAME in $expected_order; do
        # Tìm vị trí của tên trong chuỗi output
        CURRENT_POS=$(echo "$AFTER_SORT" | grep -b -o "$NAME" | cut -d: -f1 | head -n 1)
        
        if [ -z "$CURRENT_POS" ]; then
            MATCH=false
            break
        fi
        
        if [ "$CURRENT_POS" -lt "$PREV_POS" ]; then
            MATCH=false
            break
        fi
        PREV_POS=$CURRENT_POS
    done

    if [ "$MATCH" = true ]; then
        echo "✅ PASS: Danh sách đã được sắp xếp giảm dần theo GPA."
        echo "   + Input:"
        echo "$input_data"
        echo "   + Got:"
        echo "$AFTER_SORT"
    else
        echo "❌ FAIL: Thứ tự sắp xếp không chính xác hoặc thiếu thông tin."
        echo "   + Expect: $expected_order"
        echo "   + Got:"
        echo "$AFTER_SORT"
    fi
}

# 3. Chạy các Test Case đã thiết kế

# Test Case 1: Lộn xộn (David 3.9 > Charlie 3.5 > Eve 2.8) - Chọn Selection Sort (2)
run_test "1/5] Sắp xếp Selection Sort" "3\nCharlie 3 3.5 EE\nDavid 4 3.9 ME\nEve 5 2.8 CS\n2" "David Charlie Eve"

# Test Case 2: Đã sắp xếp sẵn (Frank 4.0 > Grace 3.7 > Heidi 3.1) - Chọn Insertion Sort (3)
run_test "2/5] Mảng đã sắp xếp sẵn (Insertion)" "3\nFrank 6 4.0 IT\nGrace 7 3.7 CS\nHeidi 8 3.1 EE\n3" "Frank Grace Heidi"

# Test Case 3: Trùng điểm GPA (Judy 3.8 > Ivan 3.4 & Mallory 3.4 > Niaj 2.5) - Chọn Bubble Sort (1)
# Lưu ý: Cả Ivan và Mallory đều phải nằm sau Judy và trước Niaj 
run_test "3/5] Trùng điểm GPA (Bubble Sort)" "4\nIvan 9 3.4 IT\nJudy 10 3.8 CS\nMallory 11 3.4 ME\nNiaj 12 2.5 EE\n1" "Judy Ivan Mallory Niaj"

# Test case 4:
run_test "4/5] Mảng tăng dần (Cần đảo ngược toàn bộ)" "3\nLeo 1 1.0 IT\nMia 2 2.0 CS\nNeo 3 3.0 EE\n1" "Neo Mia Leo"

# Test case 5:
run_test "5/5] Điểm thập phân sát nhau" "3\nPaul 4 3.01 EE\nQuinn 5 3.05 CS\nRose 6 3.02 IT\n2" "Quinn Rose Paul"

# 4. Dọn dẹp
rm -f "$EXECUTABLE" compile_errors.txt
echo -e "\n======================================================"
echo "                     TESTING DONE!                      "
echo "======================================================"
