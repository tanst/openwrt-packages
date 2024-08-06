#!/bin/bash

# 定义下载 URL
IPV4_URL="https://testingcf.jsdelivr.net/gh/1715173329/IPCIDR-CHINA@master/ipv4.txt"
IPV6_URL="https://testingcf.jsdelivr.net/gh/1715173329/IPCIDR-CHINA@master/ipv6.txt"

# 定义临时文件路径
IPV4_TMP_FILE="/tmp/ipv4.txt"
IPV6_TMP_FILE="/tmp/ipv6.txt"

# 下载 IPv4 和 IPv6 CIDR 列表
wget -q -O $IPV4_TMP_FILE $IPV4_URL
wget -q -O $IPV6_TMP_FILE $IPV6_URL

# 检查文件是否下载成功
if [[ ! -f $IPV4_TMP_FILE || ! -f $IPV6_TMP_FILE ]]; then
    echo "下载 IP 列表失败"
    exit 1
fi

# 读取 IPv4 CIDR 列表并拼接成一个字符串
china_ipv4=$(awk '{printf (NR>1?",":"") $0}' $IPV4_TMP_FILE)

# 读取 IPv6 CIDR 列表并拼接成一个字符串
china_ipv6=$(awk '{printf (NR>1?",":"") $0}' $IPV6_TMP_FILE)

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
