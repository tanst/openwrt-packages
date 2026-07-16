# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) Toy

include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.13.14
PKG_RELEASE:=1

ifeq ($(ARCH),aarch64)
	F_ARCH:=arm64
else ifeq ($(ARCH),x86_64)
	F_ARCH:=amd64
else
	F_ARCH:=armv7
endif


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

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/sing-box/conffiles
/etc/sing-box/
endef

define Package/sing-box/install
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(1)/usr/bin/sing-box

	$(INSTALL_DIR) $(1)/etc/sing-box
	$(INSTALL_CONF) ./files/tproxy.nft $(1)/etc/sing-box/tproxy.nft
	$(INSTALL_DIR) $(1)/etc/sing-box/scripts
	$(INSTALL_BIN) ./root/etc/sing-box/scripts/update_china_ip.sh $(1)/etc/sing-box/scripts/update_china_ip.sh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box
endef

$(eval $(call BuildPackage,sing-box))
