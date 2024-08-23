#!/bin/bash

# 定义下载 URL
URL="https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@meta/geo/geoip/cn.list"

# 使用 mktemp 创建临时文件
TMP_FILE=$(mktemp)

# 使用 curl 下载文件，并检查下载是否成功
if ! curl -s -o "$TMP_FILE" "$URL"; then
    echo "下载 IP 列表失败"
    rm -f "$TMP_FILE"
    exit 1
fi

# 读取 $TMP_FILE 并分离 IPv4 和 IPv6 地址段
china_ipv4=$(awk '/\./ {print $0}' "$TMP_FILE" | tr '\n' ',' | sed 's/,$//')
china_ipv6=$(awk '/:/ {print $0}' "$TMP_FILE" | tr '\n' ',' | sed 's/,$//')

# 删除临时文件
rm -f "$TMP_FILE"

# 清空
nft flush set inet singbox mainland_addr_v4
nft flush set inet singbox mainland_addr_v6

#新增
nft -f - <<EOF
table inet singbox {
    set mainland_addr_v4 {
        type ipv4_addr
        flags interval
        auto-merge
        elements = { $china_ipv4 }
    }
    set mainland_addr_v6 {
        type ipv6_addr
        flags interval
        auto-merge
        elements = { $china_ipv6 }
    }
}
EOF

echo "nftables china_ip 集合已更新"
