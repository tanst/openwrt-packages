#!/bin/sh

REPO="SagerNet/sing-box"
ARCH="linux-arm64"
BIN_NAME="sing-box"
INSTALL_PATH="/usr/bin/${BIN_NAME}"
TMP_DIR="/tmp/singbox_update"

# 获取整个 JSON 并压缩成易处理格式（单行 -> 多行）
ASSET_URL=$(wget -qO- "https://api.github.com/repos/${REPO}/releases/latest" | \
    tr ',' '\n' | grep "browser_download_url" | grep "${ARCH}.tar.gz" | cut -d '"' -f 4)

if [ -z "$ASSET_URL" ]; then
    echo "❌ 未找到对应架构 (${ARCH}) 的可执行包。"
    exit 1
fi

echo "✅ 找到最新版本下载地址：$ASSET_URL"

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

# 替换新版本
cp "$BIN_PATH" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo "✅ sing-box 更新完成，已安装到 ${INSTALL_PATH}"

# 检查版本
VERSION=$("$INSTALL_PATH" version)
if [ $? -ne 0 ]; then
    echo "❌ 获取版本失败。"
    exit 1
fi
echo "✅ 当前版本：$VERSION"

# 重启 sing-box 服务
/etc/init.d/sing-box restart || {
    echo "❌ 重启 sing-box 服务失败。"
    exit 1
}
echo "✅ sing-box 服务已重启。"

# 清理临时文件
cd /
rm -rf "$TMP_DIR"
