#!/bin/sh


REPO="SagerNet/sing-box"
BIN_NAME="sing-box"
INSTALL_PATH="/usr/bin/${BIN_NAME}"
TMP_DIR="/tmp/singbox_update"

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
    *) echo "❌ 不支持的架构：$ARCH"; exit 1 ;;
esac
echo "🔍 检测到系统架构：$ARCH"

# 获取当前已安装版本
if [ -x "$INSTALL_PATH" ]; then
    CURRENT_VERSION=$("$INSTALL_PATH" version 2>/dev/null | grep "^sing-box version" | awk '{print $3}')
else
    CURRENT_VERSION="none"
fi
if [ -z "$CURRENT_VERSION" ]; then
    echo "❌ 无法获取当前版本，请确保 sing-box 已安装。"
    exit 1
fi

# 获取 GitHub 最新版本 JSON 和下载地址
LATEST_JSON=$(wget -qO- "https://api.github.com/repos/${REPO}/releases/latest")

ASSET_URL=$(echo "$LATEST_JSON" | tr ',' '\n' | grep "browser_download_url" | grep "${ARCH}.tar.gz" | cut -d '"' -f 4)

if [ -z "$ASSET_URL" ]; then
    echo "❌ 未找到对应架构 (${ARCH}) 的可执行包。"
    exit 1
fi

# 从下载地址中提取版本号
LATEST_VERSION=$(echo "$ASSET_URL" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | sed 's/^v//')

echo "📌 当前版本：$CURRENT_VERSION"
echo "📦 最新版本：$LATEST_VERSION"
echo "✅ 找到最新版本下载地址：$ASSET_URL"

# 如果版本一致则跳过更新
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "✅ 当前已是最新版本，无需更新。"
    exit 0
fi
echo "🔄 开始更新 sing-box..."
# 创建临时目录
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

# 下载压缩包
wget -q "$ASSET_URL" -O "${ARCH}.tar.gz" || {
    echo "❌ 下载失败。"
    exit 1
}

# 解压文件
tar -xzf "${ARCH}.tar.gz" || {
    echo "❌ 解压失败。"
    exit 1
}

# 查找可执行文件
BIN_PATH=$(find . -type f -name "$BIN_NAME" | head -n 1)
if [ ! -f "$BIN_PATH" ]; then
    echo "❌ 未找到 sing-box 可执行文件。"
    exit 1
fi

# 停止 sing-box 服务
/etc/init.d/sing-box stop || {
    echo "❌ 停止 sing-box 服务失败。"
    exit 1
}
echo "✅ 停止 sing-box 服务成功。"

rm /usr/bin/sing-box || {
    echo "❌ 删除旧版本失败。"
    # 还原 ROM 文件系统
    mount -o remount /
    rm /usr/bin/sing-box
    exit 1
}

# 复制新版本到安装路径
cp "$BIN_PATH" "$INSTALL_PATH"
if [ $? -ne 0 ]; then
    echo "❌ 拷贝失败，错误码：$?"
    exit 1
fi
chmod +x "$INSTALL_PATH"


echo "✅ sing-box 更新完成，已安装到 ${INSTALL_PATH}"

# 重启 sing-box 服务
/etc/init.d/sing-box restart || {
    echo "❌ 重启 sing-box 服务失败。"
    exit 1
}
echo "✅ sing-box 服务已重启。"

# 检查版本
VERSION=$("$INSTALL_PATH" version)
if [ $? -ne 0 ]; then
    echo "❌ 获取版本失败。"
    exit 1
fi
echo "✅ 当前版本：$VERSION"

# 清理临时文件
cd /
rm -rf "$TMP_DIR"
