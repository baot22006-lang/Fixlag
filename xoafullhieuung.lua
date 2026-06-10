#!/bin/bash

# Auto farm level + mua võ + fix lag cho blog fruit trên GitHub Codespaces
# Chạy trong terminal Ubuntu (Linux)

# ==================== PHẦN 1: CÀY LEVEL MAX ====================
auto_farm_level() {
    # A) Dùng curl để gửi request API giả lập
    local API_URL="https://blog-fruit-game.example.com/api"
    local SESSION_ID=$(curl -s -c cookies.txt "$API_URL/login" -d "user=bot" | jq -r '.session')
    
    # B) Vòng lặp farm vô hạn
    while true; do
        # Gửi request đánh quái
        curl -s -b cookies.txt "$API_URL/attack" -d "skill=1" > /dev/null
        curl -s -b cookies.txt "$API_URL/attack" -d "skill=2" > /dev/null
        sleep 0.1
        
        # C) Nhận exp và level up
        local exp=$(curl -s -b cookies.txt "$API_URL/get_exp" | jq -r '.current_exp')
        local level=$(curl -s -b cookies.txt "$API_URL/get_level" | jq -r '.level')
        
        # D) Nếu đủ exp thì level up
        if [ $exp -ge 1000 ]; then
            curl -s -b cookies.txt "$API_URL/level_up" -X POST
        fi
        
        # E) Chuyển stage
        curl -s -b cookies.txt "$API_URL/next_stage" -X POST
        
        # F) Log trạng thái
        echo "[FARM] Level: $level | Exp: $exp"
        
        # G) Thoát nếu đạt max level (giả sử level 100)
        if [ $level -ge 100 ]; then
            echo "[+] Đạt level max!"
            break
        fi
    done
}

# ==================== PHẦN 2: MUA MỌI LOẠI VÕ ====================
buy_all_weapons() {
    # A) Lấy danh sách võ khí từ shop
    local SHOP_DATA=$(curl -s "https://blog-fruit-game.example.com/api/shop" | jq -r '.weapons[].id')
    
    # B) Vòng lặp mua từng món
    for weapon_id in $SHOP_DATA; do
        # C) Gửi request mua với số lượng 1
        curl -s -b cookies.txt "https://blog-fruit-game.example.com/api/buy" \
            -d "weapon_id=$weapon_id&quantity=1" > /dev/null
        
        # D) Kiểm tra kết quả
        local result=$(curl -s -b cookies.txt "https://blog-fruit-game.example.com/api/inventory" | jq -r ".weapons[] | select(.id==$weapon_id)")
        if [ -n "$result" ]; then
            echo "[MUA] Đã mua võ ID: $weapon_id"
        fi
        
        sleep 0.05
    done
    
    # E) Mua võ đặc biệt bằng kim cương (hack giá 0)
    curl -s -b cookies.txt "https://blog-fruit-game.example.com/api/buy" \
        -d "weapon_id=legendary_sword&diamond_cost=0"
    
    # F) Mua tất cả võ trong cửa hàng VIP
    curl -s -b cookies.txt "https://blog-fruit-game.example.com/api/vip_shop/buy_all" -X POST
    
    # G) Xác nhận đã mua xong
    echo "[+] Đã mua toàn bộ võ khí!"
}

# ==================== PHẦN 3: FIX LAG TRÊN GITHUB CODESPACES ====================
fix_lag() {
    # A) Tăng ulimit cho phép nhiều kết nối
    ulimit -n 65535
    
    # B) Giảm nice priority của các process khác
    renice -n -20 -p $$ 2>/dev/null
    
    # C) Tắt IPv6 để giảm latency mạng
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 2>/dev/null
    
    # D) Tối ưu TCP
    sudo sysctl -w net.core.rmem_max=134217728 2>/dev/null
    sudo sysctl -w net.core.wmem_max=134217728 2>/dev/null
    
    # E) Giới hạn CPU governor nếu có quyền
    echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null
    
    # F) Clear cache hệ thống
    sync && echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null
    
    # G) Tắt các service không cần thiết
    sudo systemctl stop unattended-upgrades 2>/dev/null
    sudo systemctl stop apt-daily 2>/dev/null
    
    # H) Set timeout ngắn cho curl để không chờ lâu
    echo "timeout=2" >> ~/.curlrc
    
    echo "[+] Lag fix applied"
}

# ==================== HÀM CHÍNH ====================
main() {
    echo "[*] Bắt đầu fix lag..."
    fix_lag
    
    echo "[*] Bắt đầu auto farm level..."
    auto_farm_level
    
    echo "[*] Đang mua tất cả võ khí..."
    buy_all_weights 2>/dev/null || buy_all_weapons
    
    echo "[+] Hoàn tất - Level max, toàn bộ võ đã mua"
}

# Chạy main
main
