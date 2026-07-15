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

# 1. 后缀改为 .tar.gz
PKG_SOURCE:=sing-box-linux-$(F_ARCH).tar.gz
PKG_SOURCE_URL:=https://github.com/tanst/openwrt-packages/releases/download/v$(PKG_VERSION)/
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/sing-box
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Sing-box (Static Binary)
	DEPENDS:=+ca-bundle +kmod-tun +dnsproxy
endef


define Package/sing-box/conffiles
/etc/sing-box/config.json
endef

define Package/sing-box/install
	$(INSTALL_DIR) $(1)/usr/bin
	# 直接从 PKG_BUILD_DIR 安装解压出来的 sing-box 二进制
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(1)/usr/bin/sing-box

	# 安装配置和脚本
	$(INSTALL_DIR) $(1)/etc/sing-box
	$(INSTALL_CONF) ./files/tproxy.nft $(1)/etc/sing-box/tproxy.nft
	$(INSTALL_DIR) $(1)/etc/sing-box/scripts
	$(INSTALL_BIN) ./root/etc/sing-box/scripts/update_china_ip.sh $(1)/etc/sing-box/scripts/update_china_ip.sh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box
endef

$(eval $(call BuildPackage,sing-box))