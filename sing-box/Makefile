# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) Toy

include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.13.14
PKG_RELEASE:=1

# 自动匹配当前目标架构
ifeq ($(ARCH),aarch64)
  F_ARCH:=arm64
else ifeq ($(ARCH),x86_64)
  F_ARCH:=amd64
else
  F_ARCH:=armv7
endif

# 这里填你自己的仓库地址
PKG_SOURCE:=sing-box-linux-$(F_ARCH)
PKG_SOURCE_URL:=https://github.com/tanst/openwrt-packages/releases/download/v$(PKG_VERSION)/

include $(INCLUDE_DIR)/package.mk

define Package/sing-box
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Sing-box (Static Binary)
  DEPENDS:=+ca-bundle +kmod-tun +dnsproxy
endef

define Download/sing-box
  FILE:=$(PKG_SOURCE)
  URL:=$(PKG_SOURCE_URL)
  HASH:=skip
endef
$(eval $(call Download,sing-box))

define Build/Compile
  # 直接将下载下来的二进制文件重命名以便后续处理
  cp $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/sing-box
endef

define Package/sing-box/conffiles
/etc/sing-box/
endef

define Package/sing-box/install
	# 1. 安装主程序
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(1)/usr/bin/sing-box

	# 2. 安装配置文件 (注意：官方二进制包内没有 config.json)
	# 如果你的项目目录有默认配置，请将其放在 package/.../sing-box/files/config.json 并使用下方指令
	$(INSTALL_DIR) $(1)/etc/sing-box
	# $(INSTALL_CONF) ./files/config.json $(1)/etc/sing-box/config.json

	# 3. 安装防火墙 nft 规则
	$(INSTALL_DIR) $(1)/etc/sing-box
	$(INSTALL_CONF) ./files/tproxy.nft $(1)/etc/sing-box

	# 4. 安装脚本
	$(INSTALL_DIR) $(1)/etc/sing-box/scripts
	$(INSTALL_BIN) ./root/etc/sing-box/scripts/update_china_ip.sh $(1)/etc/sing-box/scripts

	# 5. 安装 init.d 启动项
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box
endef

$(eval $(call BuildPackage,sing-box))