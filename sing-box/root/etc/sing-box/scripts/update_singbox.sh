#!/bin/sh

REPO="tanst/openwrt-packages"
BIN_NAME="sing-box"
INSTALL_PATH="/usr/bin/${BIN_NAME}"
TMP_DIR="/tmp/singbox_update"

# GitHub 下载代理（可自定义，留空则直连）
# GH_PROXY="https://pr.ty.uy/github/"
GH_PROXY=""

# 获取系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        ARCH="linux-amd64"
        ;;
    aarch64)
        ARCH="linux-arm64"
        ;;
    armv7l)
        ARCH="linux-armv7"
        ;;
    armv6l)
        ARCH="linux-armv6"
        ;;
    i386)
        ARCH="linux-386"
        ;;
    *)
        echo "❌ 不支持的架构：$ARCH"
        exit 1
        ;;
esac
echo "🔍 检测到系统架构：$ARCH"

# 获取当前已安装版本
if [ -x "$INSTALL_PATH" ]; then
    CURRENT_VERSION=$("$INSTALL_PATH" version 2>/dev/null | grep "^sing-box version" | awk '{print $3}')
else
    CURRENT_VERSION="none"
fi

if [ -z "$CURRENT_VERSION" ] || [ "$CURRENT_VERSION" = "none" ]; then
    echo "⚠️ 当前未安装 sing-box，仍将继续尝试安装或更新。"
fi

# 获取 GitHub 最新版本 JSON
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
API_URL="${GH_PROXY}${API_URL}"
LATEST_JSON=$(curl -sL "$API_URL")

# 只按架构选择，不再区分 glibc / musl
ASSET_URL=$(echo "$LATEST_JSON" | tr ',' '\n' | grep "browser_download_url" | grep "${ARCH}.tar.gz" | cut -d '"' -f 4 | head -n 1)

if [ -z "$ASSET_URL" ]; then
    echo "❌ 未找到对应架构 (${ARCH}) 的可执行包。"
    exit 1
fi

ASSET_URL="${GH_PROXY}${ASSET_URL}"

# 从下载地址中提取版本号
LATEST_VERSION=$(echo "$ASSET_URL" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | sed 's/^v//')

# 获取下载的文件名并显示版本信息
DOWNLOAD_FILE=$(echo "$ASSET_URL" | grep -oE '[^/]+\.tar\.gz$')
echo "📌 当前版本：${CURRENT_VERSION:-unknown}"
echo "📦 最新版本：$LATEST_VERSION"
echo "📥 下载文件：$DOWNLOAD_FILE"
echo "✅ 找到最新版本下载地址"

# 如果版本一致则跳过更新
if [ "$CURRENT_VERSION" != "none" ] && [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "✅ 当前已是最新版本，无需更新。"
    exit 0
fi

echo "🔄 开始更新 sing-box..."

# 创建临时目录
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

# 下载压缩包
curl -sL -o "${DOWNLOAD_FILE}" "$ASSET_URL" || {
    echo "❌ 下载失败。"
    exit 1
}

# 解压文件
tar -xzf "${DOWNLOAD_FILE}" || {
    echo "❌ 解压失败。"
    exit 1
}

# 查找可执行文件
BIN_PATH=$(find . -type f -name "$BIN_NAME" | head -n 1)
if [ ! -f "$BIN_PATH" ]; then
    echo "❌ 未找到 sing-box 可执行文件。"
    exit 1
fi

# 停止 sing-box 服务（如果存在）
if [ -f "/etc/init.d/sing-box" ]; then
    /etc/init.d/sing-box stop || {
        echo "❌ 停止 sing-box 服务失败。"
        exit 1
    }
    echo "✅ 停止 sing-box 服务成功。"
fi

# 复制二进制文件，并在空间不足时尝试 upx 压缩后再复制
copy_binary_with_upx() {
    local src="$1"
    local dst="$2"

    if cp "$src" "$dst"; then
        chmod +x "$dst"
        echo "✅ 直接复制成功"
        return 0
    fi

    echo "⚠️ 复制失败，可能是空间不足，尝试用 upx 压缩后再复制..."
    if ! command -v upx >/dev/null 2>&1; then
        echo "❌ 当前系统未安装 upx，无法继续压缩。"
        return 1
    fi

    local tmp_upx="${src}.upx"
    upx -9 -o "$tmp_upx" "$src" >/dev/null 2>&1 || {
        echo "❌ upx 压缩失败。"
        return 1
    }

    if cp "$tmp_upx" "$dst"; then
        chmod +x "$dst"
        rm -f "$tmp_upx"
        echo "✅ 已通过 upx 压缩后复制成功"
        return 0
    fi

    rm -f "$tmp_upx"
    return 1
}

# 删除旧版本
rm -f "$INSTALL_PATH" || {
    echo "⚠️ 删除旧版本失败，尝试 remount / 后再删除..."
    mount -o remount / >/dev/null 2>&1 || true
    rm -f "$INSTALL_PATH" || {
        echo "❌ 删除旧版本失败。"
        exit 1
    }
}

# 复制新版本
if ! copy_binary_with_upx "$BIN_PATH" "$INSTALL_PATH"; then
    echo "❌ 拷贝失败。"
    exit 1
fi

echo "✅ sing-box 更新完成，已安装到 ${INSTALL_PATH}"

# 重启 sing-box 服务
if [ -f "/etc/init.d/sing-box" ]; then
    /etc/init.d/sing-box restart || {
        echo "❌ 重启 sing-box 服务失败。"
        exit 1
    }
    echo "✅ sing-box 服务已重启。"
fi

# 检查版本
VERSION=$("$INSTALL_PATH" version)
if [ $? -ne 0 ]; then
    echo "❌ 获取版本失败。"
    exit 1
fi
echo "✅ 当前版本：$VERSION"

# 最后检测访问 Google Static 的延迟
echo "🔎 检测 Google Static 访问延迟..."
LATENCY_SEC=$(curl -s -o /dev/null -w "%{time_total}" https://www.gstatic.com/generate_204 2>/dev/null)

if [ -n "$LATENCY_SEC" ] && [ "$LATENCY_SEC" != "0" ]; then
    LATENCY_MS=$(awk -v s="$LATENCY_SEC" 'BEGIN { printf "%.0f", s * 1000 }')
    echo "✅ Google Static 访问延迟：${LATENCY_MS} ms"
else
    echo "❌ Google Static 访问失败，可能网络异常或被墙。"
    exit 1
fi

# 清理临时文件
cd /
rm -rf "$TMP_DIR"
