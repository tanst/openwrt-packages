#!/bin/bash

# 定义下载 URL
URL="https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@meta/geo/geoip/cn.list"
URL_Tencent="https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@meta/asn/AS132203.list"

# 使用 mktemp 创建临时文件
TMP_cn_list=$(mktemp)
TMP_Tencent_list=$(mktemp)

# 使用 curl 下载文件，并检查下载是否成功
if ! curl -s -o "$TMP_cn_list" "$URL"; then
    echo "下载 IP 列表失败"
    rm -f "$TMP_cn_list"
    exit 1
fi

if ! curl -s -o "$TMP_Tencent_list" "$URL_Tencent"; then
    echo "下载 IP 列表失败"
    rm -f "$TMP_Tencent_list"
    exit 1
fi

collection=$(cat "$TMP_cn_list"; echo; cat "$TMP_Tencent_list")

# 删除临时文件
rm -f "$TMP_cn_list"
rm -f "$TMP_Tencent_list"

TMP_collection=$(mktemp)
echo "$collection" > $TMP_collection
# 读取 $collection 并分离 IPv4 和 IPv6 地址段
china_ipv4=$(awk '/\./ {print $0}' "$TMP_collection" | tr '\n' ',' | sed 's/,$//')
china_ipv6=$(awk '/:/ {print $0}' "$TMP_collection" | tr '\n' ',' | sed 's/,$//')

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

rm -f "$TMP_collection"
